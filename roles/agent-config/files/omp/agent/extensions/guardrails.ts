import type { HookAPI } from "@oh-my-pi/pi-coding-agent/extensibility/hooks";
import { resolve, join } from "node:path";
import { homedir } from "node:os";
import { realpathSync } from "node:fs";

// ─── Blocked path patterns ────────────────────────────────────────────────────
// Supports:
//   - Absolute glob patterns  (e.g. ~/.ssh/*)
//   - Double-star globs       (e.g. **/.env)
// Add or remove entries here to adjust the policy.
const BLOCKED_PATTERNS: string[] = [
  "~/.ssh/*",
  "~/.aws/credentials",
  "~/.gnupg/*",
  "**/.env",
  "**/.env.*",
  "**/secrets.*",
];

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
//   - any language runtime reading process env directly (python os.environ, …)
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

// ─── Helpers ──────────────────────────────────────────────────────────────────

function expandHome(p: string): string {
  return p.startsWith("~/") ? join(homedir(), p.slice(2)) : p;
}

/** Convert a glob pattern into a RegExp. Handles **, *, and ? metacharacters. */
function globToRegex(pattern: string): RegExp {
  const expanded = expandHome(pattern);
  const escaped = expanded
    .replace(/[.+^${}()|[\]\\]/g, "\\$&") // escape regex specials (not * or ?)
    .replace(/\\\*\\\*/g, "__DOUBLE_STAR__")  // protect **
    .replace(/\*/g, "[^/]*")                  // * → match within one segment
    .replace(/__DOUBLE_STAR__\//g, "(?:.+/)?") // **/ → zero or more path segments
    .replace(/__DOUBLE_STAR__/g, ".*")         // trailing ** → anything
    .replace(/\?/g, "[^/]");                  // ? → single non-slash char
  return new RegExp(`^${escaped}$`);
}

const COMPILED = BLOCKED_PATTERNS.map((p) => ({
  pattern: p,
  regex: globToRegex(p),
}));

function isBlocked(filePath: string): string | null {
  const expanded = expandHome(filePath);
  // Resolve symlinks so a symlink pointing into a blocked dir is also caught.
  // Fall back to plain resolve() if the path doesn't exist yet.
  let abs: string;
  try {
    abs = realpathSync(expanded);
  } catch {
    abs = resolve(expanded);
  }
  for (const { pattern, regex } of COMPILED) {
    if (regex.test(abs)) return pattern;
  }
  return null;
}

/**
 * Extract candidate file paths from a shell command string.
 *
 * NOTE: bash coverage is best-effort only. Shell features like variable
 * expansion (`F=~/.ssh/id_rsa; cat $F`), process substitution, `find`,
 * heredocs, or `cd` into a blocked directory can all bypass this check.
 * Treat it as a speed-bump against accidental access, not a security boundary.
 *
 * Splits on whitespace/shell operators and tests each token that looks like a
 * path.
 */
function pathsInCommand(command: string): string[] {
  return command
    .split(/[\s;|&><]+/)
    .filter((tok) => tok.startsWith("/") || tok.startsWith("~") || tok.startsWith("./") || tok.startsWith("../"));
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

// ─── Hook factory ─────────────────────────────────────────────────────────────

export default function guardrails(pi: HookAPI): void {
  pi.on("tool_call", async (event, ctx) => {
    const { toolName, input } = event;

    // ── read tool ──────────────────────────────────────────────────────────────
    if (toolName === "read") {
      const path = String(input.path ?? "");
      const hit = isBlocked(path);
      if (hit) {
        return { block: true, reason: `guardrails: '${path}' matches blocked pattern '${hit}'` };
      }
    }

    // ── bash tool ─────────────────────────────────────────────────────────────
    if (toolName === "bash") {
      const command = String(input.command ?? "");
      for (const candidate of pathsInCommand(command)) {
        const hit = isBlocked(candidate);
        if (hit) {
          return { block: true, reason: `guardrails: command references '${candidate}' which matches blocked pattern '${hit}'` };
        }
      }
      const approvalRequiredFor = blockedCommandIn(command);
      if (approvalRequiredFor) {
        if (!ctx.hasUI) {
          return {
            block: true,
            reason: `guardrails: '${approvalRequiredFor}' requires interactive approval, but no UI is available`,
          };
        }
        const approved = await ctx.ui.confirm(
          `Run ${approvalRequiredFor}?`,
          `The command may expose environment variables:\n\n  ${command}`,
        );
        if (!approved) {
          return { block: true, reason: `guardrails: '${approvalRequiredFor}' was declined by user` };
        }
      }
    }
  });
}
