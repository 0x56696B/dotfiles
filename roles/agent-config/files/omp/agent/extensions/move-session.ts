/**
 * move-session.ts
 *
 * Registers the `move_session` tool so the agent can move the session working
 * directory to the launch directory or one of its direct children, without
 * stopping to ask the user to type `/move`.
 *
 * Mechanism: `/move` in the TUI runs `CommandController.handleMoveCommand`,
 * which calls `AgentSession.moveSession()` and then
 * `InteractiveMode.applyCwdChange()`. The first is public and typed
 * (`dist/types/session/agent-session.d.ts:677`); the second is not reachable
 * from an extension. Of the ten steps in `applyCwdChange`, this file performs
 * the five that matter — `setProjectDir`, `settings.reloadForCwd`,
 * `resetCapabilities()` (run inside `refreshSkills()`), skill re-discovery
 * plus system-prompt rebuild (also `refreshSkills()`), and the terminal title
 * (`ctx.ui.setTitle`, matching the `π: <label>` format
 * `formatSessionTerminalTitle` uses).
 * `setTitle` maps to `setExtensionTerminalTitle`
 * (`dist/types/utils/title-generator.d.ts:29-35`), which is verbatim and
 * sticky: it freezes the run-state separator (working/idle/attention) and
 * blocks periodic refreshes until the app calls `setSessionTerminalTitle`
 * again on an authoritative rename, new session, or focus swap. That
 * function is the one the app itself uses for cwd-driven titles, but it is
 * not exported from the package root, `sdk.d.ts`, or any extension surface
 * — `ctx.ui.setTitle` is the only reachable path, so the state indicator
 * freeze is an accepted tradeoff, not an oversight. It clears on the next
 * authoritative title set, which `title.ts` triggers via `pi.setSessionName`
 * (lines 167 and 207). `setProjectDir` comes from `@oh-my-pi/pi-utils`; an
 * extension import of that package resolves to the host's own module instance
 * (probed: `logger` is identical to `pi.pi.logger`). The status line path
 * segment reads `getProjectDir()` on every render and re-resolves its cache
 * when it changes, so this call is what makes the footer show the new folder.
 * The git watcher, project slash commands, plugin-root cache, and provider
 * globals stay scoped to the old directory; the result text says so.
 *
 * Unlike `end-session.ts` and `clear-context.ts`, this runs inline in
 * `execute()` rather than deferring to a turn boundary. `moveSession` has no
 * `isStreaming` guard, and `SessionManager.moveTo` serialises concurrent
 * session-file appends itself. Deferring would leave the session on a new cwd
 * with stale skills for the rest of the turn.
 *
 * Live session state is reached only through `pi.pi`. A bare import of
 * `AgentRegistry` from the package root loads a second copy of the module
 * graph with its own empty static registry (see `advisor-drain.ts`).
 */

import * as fs from "node:fs/promises";
import * as os from "node:os";
import * as path from "node:path";
import type { AgentSession, ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { setProjectDir } from "@oh-my-pi/pi-utils";

// ─── Move root ─────────────────────────────────────────────────────────────
// `root` is the directory `omp` was launched in. From any cwd, the agent may
// move to `root` or to a direct child of it. Every other target is refused:
// there is no prompt. Only the user changes the root, with `/move` or `!cd`.
//
// The launch directory is read once, when this module loads, and never from a
// session event. `process.cwd()` is not the launch directory: `setProjectDir`
// chdirs the process after every move, and `omp --resume` chdirs into the
// resumed session's folder before extensions load (probed 2026-10-12). The
// shell's `$PWD` is not touched by a chdir, so it still names the launch
// directory. `--cwd` is the one launch flag that moves the start on purpose,
// so with `--cwd` the process cwd is the root. State lives on `globalThis` so
// an extension reload keeps the same root.
interface MoveState {
  root: string | undefined;
  currentCwd: string | undefined;
}
const STATE_KEY = Symbol.for("neso.move-session.state");
function launchCwd(): string | undefined {
  const shellPwd = process.env.PWD;
  const hasCwdFlag = process.argv.some(arg => arg === "--cwd" || arg.startsWith("--cwd="));
  if (!hasCwdFlag && shellPwd && path.isAbsolute(shellPwd)) return path.resolve(shellPwd);
  try {
    return process.cwd();
  } catch {
    return undefined;
  }
}
const state = ((globalThis as Record<symbol, unknown>)[STATE_KEY] ??= {
  root: launchCwd(),
  currentCwd: undefined,
}) as MoveState;

/** The live main-session object, or undefined when this ctx is not it. */
function liveMoveTarget(pi: ExtensionAPI, ctx: ExtensionContext): AgentSession | undefined {
  const ref = pi.pi.AgentRegistry.global().get(pi.pi.MAIN_AGENT_ID);
  const session = ref?.session;
  if (!session) return undefined;
  // `sessionId` is a getter, not a method. Stops a subagent session from
  // moving the main session's working directory.
  if (session.sessionId !== ctx.sessionManager.getSessionId()) return undefined;
  // Feature-detect: a harness upgrade that drops either method degrades to a
  // refusal instead of throwing.
  if (typeof session.moveSession !== "function") return undefined;
  if (typeof session.refreshSkills !== "function") return undefined;
  return session;
}

function syncCwd(pi: ExtensionAPI, ctx: ExtensionContext, boundary: "turn" | "session"): void {
  if (!liveMoveTarget(pi, ctx)) return;
  const cwd = ctx.sessionManager.getCwd();
  // At a turn boundary, a cwd this tool did not set is a user `/move` or `!cd`:
  // that is the only way the root changes. A session start or switch (`/clear`,
  // resume) only records the cwd; the root survives it.
  if (boundary === "turn" && state.currentCwd !== undefined && cwd !== state.currentCwd) {
    state.root = cwd;
  }
  state.currentCwd = cwd;
}

/** Exactly one level down from `cwd`, and not `cwd` itself. A sibling, an
 *  ancestor, and a grandchild all fail: none has `cwd` as its parent. */
function isDirectChild(resolved: string, cwd: string): boolean {
  return resolved !== cwd && path.dirname(resolved) === cwd;
}

function resolveTarget(raw: string, cwd: string): string {
  const trimmed = raw.trim();
  const expanded =
    trimmed === "~" ? os.homedir() : trimmed.startsWith("~/") ? path.join(os.homedir(), trimmed.slice(2)) : trimmed;
  return path.resolve(cwd, expanded);
}

export default function moveSession(pi: ExtensionAPI) {
  const z = pi.zod;

  pi.on("session_start", async (_event, ctx) => syncCwd(pi, ctx, "session"));
  pi.on("session_switch", async (_event, ctx) => syncCwd(pi, ctx, "session"));
  pi.on("turn_start", async (_event, ctx) => syncCwd(pi, ctx, "turn"));

  pi.registerTool({
    name: "move_session",
    label: "Move session",
    description:
      "Move this session's working directory. You may move only to the directory " +
      "`omp` was launched in, or to a direct subdirectory of it. Any other target " +
      "(a parent, a deeper subdirectory such as a repo inside a task folder) is " +
      "refused, with no approval prompt. Use this after creating a working folder " +
      "so language-server and debugger config inside it is picked up, and so " +
      "relative paths resolve against it.",
    parameters: z.object({
      path: z
        .string()
        .describe(
          "Directory to move the session into: the launch directory or one of its " +
            "direct subdirectories. Anything else is refused.",
        ),
    }),
    loadMode: "essential",
    // The rule is enforced in `execute()`, which refuses. `policy: "allow"` is
    // explicit so the harness never prompts: `resolveApproval` honours an
    // explicit tool policy in every mode including the default `yolo`.
    approval: () => ({ tier: "write" as const, policy: "allow" as const }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [
            {
              type: "text",
              text:
                "move_session works only in an interactive session. Tell the user to move the " +
                "session themselves with /move.",
            },
          ],
          details: { moved: false, refused: "no-ui" },
          isError: true,
        };
      }

      const live = liveMoveTarget(pi, ctx);
      if (!live) {
        return {
          content: [
            {
              type: "text",
              text:
                "move_session can only move the main session, and only on a harness that exposes " +
                "the move. Do not retry; report this to the user.",
            },
          ],
          details: { moved: false, refused: "no-main-session" },
          isError: true,
        };
      }

      const cwd = ctx.sessionManager.getCwd();
      const resolved = resolveTarget(params.path, cwd);

      if (resolved === cwd) {
        return {
          content: [{ type: "text", text: `Already in ${resolved}.` }],
          details: { moved: false, refused: "same-directory" },
          isError: true,
        };
      }

      if (state.root === undefined) {
        return {
          content: [
            {
              type: "text",
              text: "Refused: the launch directory is unknown. Do not retry; ask the user to run /move.",
            },
          ],
          details: { moved: false, refused: "root-unknown" },
          isError: true,
        };
      }
      if (resolved !== state.root && !isDirectChild(resolved, state.root)) {
        return {
          content: [
            {
              type: "text",
              text:
                `Refused: move_session reaches only ${state.root} or a direct subdirectory of it. ` +
                `${resolved} is neither. Do not retry. Use explicit paths or \`git -C\` from the current ` +
                "directory, or ask the user to run /move.",
            },
          ],
          details: { moved: false, refused: "outside-root", root: state.root },
          isError: true,
        };
      }

      // Never create the directory. The TUI `/move` offers to create a missing
      // one because a human confirms it; an agent conjuring directories is a
      // different action from moving into one the workflow already made.
      let isDirectory = false;
      try {
        isDirectory = (await fs.stat(resolved)).isDirectory();
      } catch {
        isDirectory = false;
      }
      if (!isDirectory) {
        return {
          content: [{ type: "text", text: `Not an existing directory: ${resolved}` }],
          details: { moved: false, refused: "missing-directory" },
          isError: true,
        };
      }

      // Matches both existing move paths, which flush settings before moving.
      await pi.pi.settings.flush();
      await live.moveSession(resolved);
      state.currentCwd = ctx.sessionManager.getCwd();
      // First step of `InteractiveMode.applyCwdChange`. The status line path
      // segment reads this value, so it shows the new folder after this call.
      setProjectDir(resolved);

      // The reachable part of `InteractiveMode.applyCwdChange`. `refreshSkills`
      // also runs `resetCapabilities()` and rebuilds the base system prompt.
      await pi.pi.settings.reloadForCwd(resolved);
      await live.refreshSkills();

      ctx.ui.notify(`Session moved to ${resolved}`, "info");
      // Verbatim and sticky: this freezes the working/idle/attention title
      // separator until the app sets an authoritative title again (rename,
      // new session, focus swap, or `/title`). See the header comment for
      // why this is the only reachable title API from an extension.
      ctx.ui.setTitle(`π: ${live.sessionName ?? path.basename(resolved)}`);

      return {
        content: [
          {
            type: "text",
            text:
              `Moved session to ${resolved}. Relative paths, lsp config, skills, and settings now ` +
              `resolve against this directory, and the terminal title and status line path now ` +
              `show it too. The status line git segment, project slash commands, and MCP servers ` +
              `are unchanged — that is expected, not a failed move.`,
          },
        ],
        details: { moved: true, from: cwd, to: resolved },
      };
    },
  });
}
