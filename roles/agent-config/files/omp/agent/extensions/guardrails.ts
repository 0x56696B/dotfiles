import type { HookAPI } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";
import { resolve, join } from "node:path";
import { homedir } from "node:os";
import { realpathSync } from "node:fs";

// ─── Hard-blocked path patterns ────────────────────────────────────────────
// Always denied outright, no prompt. Reserved for material that should
// never be visible to the agent under any circumstance (private keys,
// cloud credentials, anything named "secrets").
// Supports:
//   - Absolute glob patterns  (e.g. ~/.ssh/*)
//   - Double-star globs       (e.g. **/.env)
// Add or remove entries here to adjust the policy.
const HARD_BLOCKED_PATTERNS: string[] = [
  "~/.ssh/*",
  "~/.aws/credentials",
  "~/.gnupg/*",
  "**/secrets.*",
];

// ─── Confirm-required path patterns ────────────────────────────────────────
// Same glob syntax as above, but access prompts for interactive approval
// (ctx.ui.confirm) instead of being denied outright. Use this for files that
// are sometimes legitimately needed (.env during debugging) but should
// never be read silently.
const CONFIRM_PATTERNS: string[] = ["**/.env", "**/.env.*"];

// ─── Blocked commands ──────────────────────────────────────────────────────────
// Base command names (argv[0], basename only — e.g. "env" also catches
// "/usr/bin/env") that prompt for approval whenever they appear in COMMAND
// POSITION, not merely as text/arguments elsewhere in the line (so "echo env
// vars" and "grep env file" are NOT prompted, but "env", "sudo env", "cmd
// && printenv", "FOO=bar env" are).
//
// KNOWN BYPASSES (documented, not fixed — this is a guardrail, not a sandbox):
//   - command substitution: echo $(env), echo `printenv`
//   - indirection through an interpreter: bash -c env, sh -c printenv
//   - variable indirection: X=env; $X
//   - wrapper flags: "sudo -u other env" or "nice -n 5 env" are NOT
//     unwrapped — the flag/value token is (wrongly) treated as argv0, so the
//     real command escapes detection. Flag-aware unwrapping per-wrapper is
//     deliberately not implemented (unbounded shell-syntax special-casing).
//   - double-quoted line continuation: "e\<newline>nv" is elided by the real
//     shell inside double quotes too (POSIX escapes $, `, ", \, newline
//     there); this detector only elides it when UNquoted, so a double-quoted
//     line-continuation spelling of "env" is not currently caught.
//   - aliases/shell functions named differently that exec into env/printenv
//   - any language runtime reading process env directly OTHER than python's
//     `os.environ`/`os.getenv` (node process.env, ruby ENV, perl %ENV, php
//     getenv() are not covered) — see PYTHON_ENV_ACCESS_RE below for python.
// Add or remove entries here to adjust the policy.
const BLOCKED_COMMANDS: string[] = ["env", "printenv"];

// Leading wrapper commands stripped before checking the real argv0 (each may
// itself be preceded by more VAR=value assignments, which are stripped too).
// Only wrappers commonly invoked flag-free are listed — see bypass note above.
const COMMAND_WRAPPERS: Record<string, true> = {
  sudo: true,
  command: true,
  exec: true,
  nohup: true,
};

// ─── Python env-variable access ────────────────────────────────────────────
// Best-effort detection of Python code — inline `-c`, or embedded in a
// nested interpreter call — that reads process environment variables. This
// closes the most common bypass of BLOCKED_COMMANDS above: `env`/`printenv`
// are blocked, but `python3 -c "import os; print(os.environ)"` reads the
// same data and is not a "command" match.
//
// Matched against the FULL command text, not just argv0 position, so it
// also catches indirection like `bash -c "python3 -c '...'"`.
//
// KNOWN BYPASSES (documented, not fixed):
//   - a python SCRIPT FILE (not inline -c) that reads os.environ internally
//     is invisible to a static command-line check.
//   - equivalent but unlisted spellings (os.environb, ctypes/FFI getenv,
//     subprocess.run(["env"])) are not matched.
//   - other language runtimes (node, ruby, perl, php, …) are not covered.
// Add or broaden the regexes below to adjust the policy.
const PYTHON_INTERPRETER_RE = /\b(?:python3?|python2|ipython3?|py)\b/;
const PYTHON_ENV_ACCESS_RE = /\bos\.environ\b|\bos\.getenv\s*\(|\bgetenv\s*\(|\benviron\b/;

/** True if the command mentions a python interpreter AND an env-reading pattern. */
function pythonEnvAccessIn(command: string): boolean {
  return PYTHON_INTERPRETER_RE.test(command) && PYTHON_ENV_ACCESS_RE.test(command);
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

function expandHome(p: string): string {
  return p.startsWith("~/") ? join(homedir(), p.slice(2)) : p;
}

/** Convert a glob pattern into a RegExp. Handles **, *, and ? metacharacters. */
function globToRegex(pattern: string): RegExp {
  const expanded = expandHome(pattern);
  const escaped = expanded
    .replace(/[.+^${}()|[\]\\]/g, "\\$&")       // escape regex specials (not * or ?)
    .replace(/\*\*\//g, "__DOUBLE_STAR_SLASH__") // **/ → zero or more path segments (protect before *)
    .replace(/\*\*/g, "__DOUBLE_STAR__")         // trailing/bare ** → anything (protect before *)
    .replace(/\*/g, "[^/]*")                     // remaining * → match within one segment
    .replace(/\?/g, "[^/]")                      // glob ? → single non-slash char — MUST run
    // before the placeholder restores below, which introduce their own
    // literal "?" as regex syntax ("(?:.+/)?"); doing this after would
    // corrupt that syntax by treating it as a glob wildcard too.
    .replace(/__DOUBLE_STAR_SLASH__/g, "(?:.+/)?")
    .replace(/__DOUBLE_STAR__/g, ".*");
  return new RegExp(`^${escaped}$`);
}

/**
 * Strip a trailing read/grep-tool selector (":50", ":50-200", ":50+150",
 * ":raw", ":2-4:raw", ":raw:2-4", ":conflicts", …) from a path so matching
 * happens against the real file path, not the selector text — otherwise
 * `.env:raw` fails to resolve and slips past every glob below.
 */
function stripSelector(path: string): string {
  const SELECTOR = /(?::(?:raw|conflicts|\d+(?:[-+]\d*)?(?:,\d+(?:[-+]\d*)?)*)){1,2}$/i;
  return path.replace(SELECTOR, "");
}

const COMPILED_BLOCKED = HARD_BLOCKED_PATTERNS.map((p) => ({
  pattern: p,
  regex: globToRegex(p),
}));
const COMPILED_CONFIRM = CONFIRM_PATTERNS.map((p) => ({
  pattern: p,
  regex: globToRegex(p),
}));

function matchPattern(filePath: string, compiled: { pattern: string; regex: RegExp }[]): string | null {
  const expanded = expandHome(filePath);
  // Resolve symlinks so a symlink pointing into a blocked dir is also caught.
  // Fall back to plain resolve() if the path doesn't exist yet.
  let abs: string;
  try {
    abs = realpathSync(expanded);
  } catch {
    abs = resolve(expanded);
  }
  for (const { pattern, regex } of compiled) {
    if (regex.test(abs)) return pattern;
  }
  return null;
}

/** Hard-blocked: denied outright, no prompt. */
function isHardBlocked(filePath: string): string | null {
  return matchPattern(filePath, COMPILED_BLOCKED);
}

/** Confirm-required: prompts for interactive approval before allowing access. */
function isConfirmRequired(filePath: string): string | null {
  return matchPattern(filePath, COMPILED_CONFIRM);
}

/**
 * Extract every non-flag token from a shell command string, one top-level
 * segment (split on unquoted ; | || & && newlines) at a time, quote-aware.
 *
 * NOTE: bash coverage is best-effort only. Shell features like variable
 * expansion (`F=~/.ssh/id_rsa; cat $F`), process substitution, `find`,
 * heredocs, or `cd` into a blocked directory can all bypass this check.
 * Treat it as a speed-bump against accidental access, not a security
 * boundary.
 *
 * Deliberately does NOT filter by leading path character (`/`, `~`, `./`) —
 * `cat .env` or `grep secret secrets.txt` reference sensitive files with a
 * bare relative name, and dropping the filter costs nothing for the
 * confirm-tier (an unrelated token just fails to match and adds no prompt).
 * It DOES mean a hard-blocked basename glob (the secrets.* entry) can trigger on
 * prose that merely mentions the name (e.g. `echo secrets.txt`) — accepted
 * tradeoff: missing a real bare-name read is worse than an occasional
 * over-eager block on a hard-blocked pattern.
 */
function pathsInCommand(command: string): string[] {
  const out: string[] = [];
  for (const segment of splitTopLevelSegments(command)) {
    for (const tok of tokenize(segment)) {
      if (tok && !tok.startsWith("-")) out.push(tok);
    }
  }
  return out;
}

/**
 * Quote-aware split of a shell command line into top-level segments on
 * unquoted ; | || & && and newlines. Parenthesized command substitutions
 * ($( ... )) are treated as opaque (not split into) so an operator inside
 * one doesn't fracture the outer segment.
 */
function splitTopLevelSegments(command: string): string[] {
  const segments: string[] = [];
  let cur = "";
  let quote: '"' | "'" | null = null;
  let parenDepth = 0;
  for (let i = 0; i < command.length; i++) {
    const c = command[i];
    if (quote) {
      cur += c;
      if (c === quote && command[i - 1] !== "\\") quote = null;
      continue;
    }
    if (c === "\\" && i + 1 < command.length) {
      // Unquoted backslash escapes the next char literally — it is never an
      // operator, quote-opener, or command-substitution starter even if the
      // escaped char would otherwise be one (e.g. "echo \; env" is ONE
      // command; \; is a literal semicolon argument to echo, not a separator).
      cur += c + command[i + 1];
      i++;
      continue;
    }
    if (c === "'" || c === '"') {
      quote = c;
      cur += c;
      continue;
    }
    if (c === "$" && command[i + 1] === "(") {
      parenDepth++;
      cur += c;
      continue;
    }
    if (parenDepth > 0) {
      if (c === "(") parenDepth++;
      else if (c === ")") parenDepth--;
      cur += c;
      continue;
    }
    if (c === ";" || c === "|" || c === "&" || c === "\n") {
      let j = i;
      while (j < command.length && "|&;\n".includes(command[j])) j++;
      segments.push(cur);
      cur = "";
      i = j - 1;
      continue;
    }
    cur += c;
  }
  segments.push(cur);
  return segments.map((s) => s.trim()).filter(Boolean);
}

/** Quote-aware whitespace tokenizer; strips (but does not interpret) quotes. */
function tokenize(segment: string): string[] {
  const tokens: string[] = [];
  let cur = "";
  let quote: '"' | "'" | null = null;
  let has = false;
  for (let i = 0; i < segment.length; i++) {
    const c = segment[i];
    if (quote) {
      if (c === quote && segment[i - 1] !== "\\") {
        quote = null;
      } else {
        cur += c;
      }
      has = true;
      continue;
    }
    if (c === "\\" && i + 1 < segment.length) {
      // Unquoted backslash escapes the next char literally (not a token
      // separator, quote-opener, etc.), mirroring splitTopLevelSegments —
      // EXCEPT backslash-newline ("line continuation"), which the real
      // shell elides entirely (no literal char is inserted): "e\<NL>nv"
      // executes "env", not "e<NL>nv".
      if (segment[i + 1] === "\n") {
        i++;
        continue;
      }
      cur += segment[i + 1];
      has = true;
      i++;
      continue;
    }
    if (c === "'" || c === '"') {
      quote = c;
      has = true;
      continue;
    }
    if (/\s/.test(c)) {
      if (has) tokens.push(cur);
      cur = "";
      has = false;
      continue;
    }
    cur += c;
    has = true;
  }
  if (has) tokens.push(cur);
  return tokens;
}

/**
 * Resolve the real argv[0] basename of a single command segment, skipping
 * leading VAR=value assignments and known no-op wrapper commands (sudo,
 * command, exec, nice, nohup, ionice), each of which may itself be preceded
 * by more assignments.
 */
function argv0Of(segment: string): string | null {
  const tokens = tokenize(segment);
  let i = 0;
  const skipAssignments = () => {
    while (i < tokens.length && /^[A-Za-z_][A-Za-z0-9_]*=/.test(tokens[i])) i++;
  };
  skipAssignments();
  while (i < tokens.length) {
    const base = tokens[i].split("/").pop() ?? tokens[i];
    if (COMMAND_WRAPPERS[base]) {
      i++;
      skipAssignments();
      continue;
    }
    break;
  }
  const cmd = tokens[i];
  if (!cmd) return null;
  return cmd.split("/").pop() ?? cmd;
}

/** Return the first blocked command name found in command position, else null. */
function blockedCommandIn(command: string): string | null {
  for (const segment of splitTopLevelSegments(command)) {
    const base = argv0Of(segment);
    if (base && BLOCKED_COMMANDS.includes(base)) return base;
  }
  return null;
}

// ─── Browser auth-artifact protection (NESO headless-login profile) ───────
// The persistent Chrome profile at ~/.neso-auth/chrome-profile/ holds a
// captured, already-authenticated NESO/Entra ID SSO session (cookies,
// localStorage, IndexedDB) for the workbench-fe headless browser. Its
// CONTENTS are covered by HARD_BLOCKED_PATTERNS above (read/grep/bash), but
// a file-path check alone is not enough: two other channels can smuggle the
// same secret out without ever "reading a file":
//
//   1. Any tool that accepts the profile path as DATA (not as "the thing to
//      read") could be pointed at it — e.g. the native `browser` tool's
//      `open.app.path` + `app.args: ["--user-data-dir=<profile>"]` would
//      spawn an independent, fully authenticated Chrome instance the agent
//      then drives with arbitrary JS via `run`. `eval` (py/js) could also be
//      handed the path as a string to open/read/zip/upload it directly.
//   2. A browser-automation tool that can execute arbitrary JS *inside an
//      already-open authenticated tab* (document.cookie, localStorage,
//      sessionStorage, indexedDB) reads the live secret without the profile
//      PATH ever appearing anywhere in the call — see BLOCKED_MCP_TOOL_NAMES
//      below, which denies those specific tool names outright rather than
//      trying to pattern-match arbitrary JS (trivially obfuscatable via
//      property-access tricks like `document['coo'+'kie']`).
//
// (1) is closed by referencesProtectedArtifact() — a blunt, tool-agnostic
// literal-substring scan applied to every tool_call's input before any
// tool-specific logic runs.
const PROTECTED_ARTIFACT_PATHS: string[] = [expandHome("~/.neso-auth/chrome-profile")];

/**
 * True (returning the matched path) if the protected profile path appears
 * ANYWHERE in a tool call's input, regardless of which field or tool.
 *
 * KNOWN BYPASSES (documented, not fixed): only matches the literal absolute
 * path string. A path rebuilt via concatenation, an unexpanded `~`, an env
 * var, or a symlink alias is invisible to a substring check — same
 * best-effort caveat as the rest of this file.
 */
function referencesProtectedArtifact(input: unknown): string | null {
  let text: string;
  try {
    text = JSON.stringify(input) ?? "";
  } catch {
    text = String(input);
  }
  for (const p of PROTECTED_ARTIFACT_PATHS) {
    if (text.includes(p)) return p;
  }
  return null;
}

// MCP tool names (see the "playwright" server in mcp.json, wired to the
// protected profile above) that read live, in-session secrets through the
// authenticated page itself rather than through the filesystem — denied
// outright, no confirm tier, because arbitrary-JS payload inspection is
// trivially evadable and there is no legitimate use of these specific tools
// on a server whose only purpose is driving one authenticated NESO session:
//   - browser_evaluate / browser_run_code_unsafe: arbitrary JS/Playwright
//     code with full access to document.cookie, localStorage,
//     sessionStorage, indexedDB, and (run_code_unsafe) the Playwright server
//     process itself.
//   - browser_network_request(s): returns raw request/response headers,
//     which can include the OIDC `Authorization: Bearer <token>` the app
//     attaches to its own API calls.
//   - browser_console_messages: returns all console output verbatim, which
//     can echo logged tokens/session data some apps print for debugging.
// Mirrored in ~/.omp/agent/config.yml (`tools.approval.mcp__playwright_*`)
// as a second, independent layer — either one alone is sufficient to deny.
const BLOCKED_MCP_TOOL_NAMES: Record<string, true> = {
  mcp__playwright_browser_evaluate: true,
  mcp__playwright_browser_run_code_unsafe: true,
  mcp__playwright_browser_network_request: true,
  mcp__playwright_browser_network_requests: true,
  mcp__playwright_browser_console_messages: true,
};

// ─── Hook factory ─────────────────────────────────────────────────────────────

export default function guardrails(pi: HookAPI): void {
  pi.on("tool_call", async (event, ctx) => {
    const { toolName, input } = event;

    // ── Cross-tool protected-artifact guard (checked before anything else) ──
    const artifactHit = referencesProtectedArtifact(input);
    if (artifactHit) {
      return {
        block: true,
        reason: `guardrails: '${toolName}' call references the protected auth artifact '${artifactHit}' — its contents may never reach the agent through any tool`,
      };
    }
    if (BLOCKED_MCP_TOOL_NAMES[toolName]) {
      return {
        block: true,
        reason: `guardrails: '${toolName}' is permanently denied — it can read live session secrets (cookies/localStorage/headers) from the authenticated NESO browser profile`,
      };
    }

    /** Prompt for approval; returns a block result on decline/no-UI, else undefined. */
    const confirmAccess = async (
      title: string,
      detail: string,
      label: string,
    ): Promise<{ block: true; reason: string } | undefined> => {
      if (!ctx.hasUI) {
        return { block: true, reason: `guardrails: '${label}' requires interactive approval, but no UI is available` };
      }
      const approved = await ctx.ui.confirm(title, detail);
      if (!approved) {
        return { block: true, reason: `guardrails: '${label}' was declined by user` };
      }
      return undefined;
    };

    /**
     * Hard-block or confirm-prompt a single content-exposing path. Shared by
     * `read` and `grep` — both can return file CONTENTS, unlike `glob`
     * (names only, intentionally not gated). Strips read/grep selectors
     * (":50", ":raw", …) before matching.
     */
    const checkContentPath = async (
      rawPath: string,
      verb: string,
    ): Promise<{ block: true; reason: string } | undefined> => {
      const path = stripSelector(rawPath);
      const hardHit = isHardBlocked(path);
      if (hardHit) {
        return { block: true, reason: `guardrails: '${rawPath}' matches blocked pattern '${hardHit}'` };
      }
      const confirmHit = isConfirmRequired(path);
      if (confirmHit) {
        return confirmAccess(
          `${verb} ${rawPath}?`,
          `This path matches the confirm-required pattern '${confirmHit}' and likely contains secrets.`,
          `${verb.toLowerCase()} ${rawPath}`,
        );
      }
      return undefined;
    };

    // ── read tool ──────────────────────────────────────────────────────────────
    if (toolName === "read") {
      const denial = await checkContentPath(String(input.path ?? ""), "Read");
      if (denial) return denial;
    }

    // ── grep tool ─────────────────────────────────────────────────────────────
    // `path` may be a semicolon-delimited list of roots, each possibly
    // carrying a ":<lines>" selector; grep returns matching LINE CONTENT so
    // it is exactly as sensitive as `read`.
    if (toolName === "grep") {
      const roots = String(input.path ?? ".")
        .split(";")
        .map((s) => s.trim())
        .filter(Boolean);
      for (const root of roots) {
        const denial = await checkContentPath(root, "Search");
        if (denial) return denial;
      }
    }

    // ── bash tool ─────────────────────────────────────────────────────────────
    if (toolName === "bash") {
      const command = String(input.command ?? "");

      for (const candidate of pathsInCommand(command)) {
        const hardHit = isHardBlocked(candidate);
        if (hardHit) {
          return { block: true, reason: `guardrails: command references '${candidate}' which matches blocked pattern '${hardHit}'` };
        }
      }

      for (const candidate of pathsInCommand(command)) {
        const confirmHit = isConfirmRequired(candidate);
        if (confirmHit) {
          const denial = await confirmAccess(
            `Run command referencing '${candidate}'?`,
            `This command references a path matching the confirm-required pattern '${confirmHit}':\n\n  ${command}`,
            `command referencing '${candidate}'`,
          );
          if (denial) return denial;
        }
      }

      const approvalRequiredFor = blockedCommandIn(command);
      if (approvalRequiredFor) {
        const denial = await confirmAccess(
          `Run ${approvalRequiredFor}?`,
          `The command may expose environment variables:\n\n  ${command}`,
          approvalRequiredFor,
        );
        if (denial) return denial;
      }

      if (pythonEnvAccessIn(command)) {
        const denial = await confirmAccess(
          "Allow Python environment-variable access?",
          `The command appears to read process environment variables from Python:\n\n  ${command}`,
          "python env access",
        );
        if (denial) return denial;
      }
    }
  });
}
