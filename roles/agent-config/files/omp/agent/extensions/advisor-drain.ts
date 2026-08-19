/**
 * advisor-drain.ts
 *
 * Holds a session busy at turn end until every advisor finishes, so an
 * in-flight vault write (or any other advisor side effect) is not lost when
 * the turn ends and the UI, or the process, moves on.
 *
 * `AgentSession.waitForAdvisorCatchup(timeoutMs)` awaits every advisor's
 * backlog down to zero, plus pending advisor-card persistence. It returns
 * `false` on deadline expiry or advisor failure. There is no public
 * per-advisor busy read, so this drains all advisors, not one by name.
 *
 * Live-tested cap: the harness enforces its own hard ceiling on every
 * `turn_end` hook handler, `EXTENSION_HANDLER_TIMEOUT_MS` (30s), with no
 * per-event override. A `timeoutMs` at or above that ceiling never runs to
 * completion: the host aborts the handler at 30s and logs "handler timed
 * out", regardless of the value passed here. `HOOK_DRAIN_TIMEOUT_MS` stays
 * a safety margin under that fixed ceiling.
 *
 * `drainAdvisors` is also called from `end-session.ts`, inside a tool
 * `execute()` call, not a hook handler. That path has no 30s host ceiling,
 * so it passes its own, longer cap.
 */

import type { AgentSession, ExtensionAPI, ExtensionContext } from "@oh-my-pi/pi-coding-agent";

const HOOK_DRAIN_TIMEOUT_MS = 25_000;

// ─── Live session access ───────────────────────────────────────────────────
// Reach live session state only through `pi.pi`. A bare import of
// `AgentRegistry` from the package root loads a second copy of the module
// graph with its own static registry, which always reads as empty.
function liveMainSession(pi: ExtensionAPI, ctx: ExtensionContext): AgentSession | undefined {
  const ref = pi.pi.AgentRegistry.global().get(pi.pi.MAIN_AGENT_ID);
  const session = ref?.session;
  if (!session) return undefined;
  // `sessionId` is a getter, not a method. This comparison stops a subagent
  // session from draining on the main session's behalf.
  if (session.sessionId !== ctx.sessionManager.getSessionId()) return undefined;
  // Feature-detect: a harness upgrade that drops the method degrades to no
  // drain instead of throwing on every turn.
  if (typeof session.waitForAdvisorCatchup !== "function") return undefined;
  return session;
}

/**
 * Wait for every advisor on the live main session to finish, up to
 * `timeoutMs`. Does nothing when the session is missing, is a subagent
 * session, or the harness does not expose the drain method.
 */
export async function drainAdvisors(pi: ExtensionAPI, ctx: ExtensionContext, timeoutMs: number): Promise<void> {
  const live = liveMainSession(pi, ctx);
  if (!live) return;
  // The harness already logs the abandoned-work warning on `false`. A UI
  // notification on every slow turn would be noise, so this stays silent
  // either way.
  await live.waitForAdvisorCatchup(timeoutMs);
}

export default function advisorDrain(pi: ExtensionAPI): void {
  pi.on("turn_end", async (_event, ctx) => {
    await drainAdvisors(pi, ctx, HOOK_DRAIN_TIMEOUT_MS);
  });
}
