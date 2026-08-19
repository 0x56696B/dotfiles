/**
 * end-session.ts
 *
 * Registers the `end_session` tool so the agent can close the session when
 * the user asks for it, instead of telling the user to type `/exit`.
 *
 * Mechanism: `/exit` in the TUI calls the controller's `shutdown()`.
 * `ctx.shutdown()` from a tool sets the TUI `shutdownRequested` flag, and
 * the TUI calls `checkShutdownRequested()` after the current submission
 * settles. The exit is therefore graceful and deferred to the end of the
 * turn: the session disposes, and omp prints its normal
 * "Resume this session with ... --resume <id>" line.
 *
 * `ctx.shutdown()` is a no-op in subagent and ACP contexts, and an
 * immediate `process.exit(0)` in print mode. Both are wrong or useless for
 * this tool, so the tool refuses to run when `ctx.hasUI` is false.
 *
 * Before scheduling shutdown, this awaits `drainAdvisors` (see
 * `advisor-drain.ts`) so an in-flight vault write finishes before the
 * process exits. `session_shutdown` fires but is not awaited, so this is
 * the one exit path this code controls; `/exit` typed by the user still
 * exits without draining.
 *
 * This call runs inside a tool `execute()`, not a hook handler, so it is
 * not subject to the harness's 30s `EXTENSION_HANDLER_TIMEOUT_MS` ceiling
 * that caps every `turn_end` handler (see `advisor-drain.ts`). It can use
 * a longer cap.
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";
import { drainAdvisors } from "./advisor-drain";

const DRAIN_TIMEOUT_MS = 45_000;

export default function endSession(pi: ExtensionAPI) {
  const z = pi.zod;

  pi.registerTool({
    name: "end_session",
    label: "End Session",
    description:
      "Close this omp session. Same effect as the user typing /exit: the session saves, " +
      "the process exits after the current turn ends, and omp prints the resume command. " +
      "Call this only when the user asks in plain words to close, end, quit, or exit the " +
      "session. Never call it on your own initiative, never to escape a hard task, and " +
      "never while work the user asked for is unfinished.",
    parameters: z.object({
      reason: z.string(),
    }),
    loadMode: "essential",
    approval: "read",
    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (!ctx.hasUI) {
        return {
          content: [
            {
              type: "text",
              text:
                "end_session works only in an interactive session. Tell the user to close " +
                "this session themselves.",
            },
          ],
          details: { closing: false, reason: params.reason, refused: "no-ui" },
          isError: true,
        };
      }

      if (ctx.hasPendingMessages()) {
        return {
          content: [
            {
              type: "text",
              text:
                "Queued messages are still pending. Session close is cancelled. Report the " +
                "queued work to the user and ask which to run first.",
            },
          ],
          details: { closing: false, reason: params.reason, refused: "pending-messages" },
          isError: true,
        };
      }

      await drainAdvisors(pi, ctx, DRAIN_TIMEOUT_MS);
      ctx.shutdown();
      ctx.ui.notify(`Closing session: ${params.reason}`, "info");

      return {
        content: [
          {
            type: "text",
            text:
              "Session close is scheduled. The session exits when this turn ends. Write one " +
              "short closing line, then stop.",
          },
        ],
        details: { closing: true, reason: params.reason },
      };
    },
  });
}
