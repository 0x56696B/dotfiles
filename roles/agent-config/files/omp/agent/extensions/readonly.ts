/**
 * readonly.ts
 *
 * Registers the `/readonly` slash command: a minimal-token, look-things-up-only
 * mode, the same shape as the built-in `/vibe`. Toggling it on strips the
 * active toolset down to `read`, `grep`, `glob`, `web_search`, `ask`, `task`,
 * and `end_session`, replaces the system prompt for every turn with a compact
 * read-only prompt (plus the verbatim contents of `APPEND_SYSTEM.md`, so the
 * ASD-STE100 writing standard and other user-level rules still apply), and
 * restricts the `task` tool to spawning the `scout` agent only. Toggling it
 * off restores the exact toolset and prompt that were active before.
 *
 * `setActiveTools` hides an inactive tool from the model but is not a lock —
 * e.g. connecting an MCP server can union tools back into the active set —
 * so a `tool_call` guard below fails closed on anything outside the allowlist
 * and on any non-`scout` agent passed to `task`, independent of what the
 * active toolset currently reports.
 *
 * State is keyed by session id, not a bare module-level flag: extension
 * modules are process-wide and shared with subagent sessions that load them,
 * so a global flag would leak the parent session's mode into a child.
 *
 * Advisors are untouched by this extension. It never calls
 * `applyAdvisorConfigs` or otherwise touches the advisor roster.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import type { AgentSession, ExtensionAPI, ExtensionCommandContext, ExtensionContext } from "@oh-my-pi/pi-coding-agent";
import { liveMainSession } from "./advisor-drain";

// ─── Constants ─────────────────────────────────────────────────────────────
const STATE_TYPE = "readonly-mode";
const STATUS_KEY = "readonly";

/** Tool names kept active. Intersected with the live registry at apply time. */
const READONLY_TOOLS = ["read", "grep", "glob", "web_search", "ask", "task", "end_session", "clear_context"];

/** Only agent the `task` tool may spawn while the mode is on. */
const ALLOWED_AGENTS = new Set(["scout"]);

const USAGE = "Usage: /readonly [on|off|status]";

// ─── Compact read-only system prompt ──────────────────────────────────────
const READONLY_PROMPT = `You are a read-only research assistant in an omp session. You answer questions by looking things up. You never change the system.

# Tools

\`read\`, \`grep\`, \`glob\`, \`web_search\`, \`ask\`, \`task\`, \`end_session\`, \`clear_context\`. This session has no edit, write, bash, eval, lsp, or debug tool. Do not plan work that needs one. If an answer implies a file change, describe the change. Do not attempt it.

# Delegation

Delegate wide or deep lookups to \`scout\` subagents. \`scout\` is the only agent you may spawn. Every other agent is blocked. A scout searches and reads on a fast model, then returns a compressed report, so the answer costs this session few tokens.

- Put independent lookups in one \`task\` call as a \`tasks[]\` batch. They run in parallel.
- Give each scout a complete brief: exact paths or search terms, the question, and the answer shape you need. A scout starts blank. It never sees this conversation.
- Read a file yourself for one short region. Delegate when the search is open-ended, spans many files, or needs full-file reads.
- Scout results deliver by themselves when the scout finishes. Do not poll.

# Grounding

Cite a file path with a line range, or a URL, for every fact you report. Read the source in this session. Never answer from memory alone. Say "not found" when a search returns nothing, and name what you searched.

# Answers

Give the direct answer first. Keep it short. Add evidence, not background.

# Internal URLs

\`read\` and \`grep\` accept these: \`vault://<vault>/<path>\`, \`omp://<doc>\`, \`skill://<name>\`, \`rule://<name>\`, \`memory://root\`, \`issue://<N>\`, \`pr://<N>\`, \`agent://<id>\`, \`history://<id>\`, \`local://<name>.md\`, \`artifact://<id>\`, \`mcp://<uri>\`, \`ssh://host/<path>\`.

# Drafted messages

If you draft a message for the user to send, end it with the line [AI-drafted, unreviewed].`;

// `APPEND_SYSTEM.md` supplies wiki context, the mandatory ASD-STE100 writing
// standard, and the session-close rule, so those survive the prompt
// replacement. Loaded lazily (the agent dir is not known until a session
// exists) and cached: the file never changes mid-process.
let appendSystemCache: string | null | undefined;

function appendSystemText(pi: ExtensionAPI): string | null {
  if (appendSystemCache !== undefined) return appendSystemCache;
  try {
    const file = path.join(pi.pi.getAgentDir(), "APPEND_SYSTEM.md");
    appendSystemCache = fs.readFileSync(file, "utf8").trim() || null;
  } catch {
    appendSystemCache = null;
  }
  return appendSystemCache;
}

// ─── Session state ─────────────────────────────────────────────────────────
interface ReadonlyState {
  active: boolean;
  previousTools: string[];
}

const states = new Map<string, ReadonlyState>();

function stateFor(ctx: ExtensionContext): ReadonlyState {
  const key = ctx.sessionManager.getSessionId();
  let state = states.get(key);
  if (!state) {
    state = { active: false, previousTools: [] };
    states.set(key, state);
  }
  return state;
}

// ─── Toolset ───────────────────────────────────────────────────────────────
function targetTools(pi: ExtensionAPI): string[] {
  const registered = new Set(pi.getAllTools().map((tool) => tool.name));
  return READONLY_TOOLS.filter((name) => registered.has(name));
}

// ─── Mode conflicts ────────────────────────────────────────────────────────
// `/readonly` is a toolset/prompt swap of the same shape as plan, goal, and
// vibe mode. Stacking with any of them is refused rather than silently
// clobbered or silently ignored.
function conflictingMode(live: AgentSession | undefined): string | null {
  if (!live) return null;
  if (live.getPlanModeState?.()?.enabled) return "plan";
  if (live.getGoalModeState?.()?.enabled) return "goal";
  if (live.getVibeModeState?.()?.enabled) return "vibe";
  return null;
}

// ─── Enter and exit ────────────────────────────────────────────────────────
async function enter(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
  const state = stateFor(ctx);
  if (state.active) return;

  const conflict = conflictingMode(liveMainSession(pi, ctx));
  if (conflict) {
    ctx.ui.notify(`Exit ${conflict} mode first.`, "warning");
    return;
  }

  const previousTools = pi.getActiveTools();
  await pi.setActiveTools(targetTools(pi));
  state.active = true;
  state.previousTools = previousTools;
  pi.appendEntry(STATE_TYPE, { mode: "on", previousTools });
  ctx.ui.setStatus(STATUS_KEY, "Readonly");
  ctx.ui.notify(
    "Readonly mode on. Tools: read, grep, glob, web_search, ask, task. Delegate research to scout subagents.",
    "info",
  );
}

async function exit(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
  const state = stateFor(ctx);
  if (!state.active) return;

  if (state.previousTools.length > 0) {
    await pi.setActiveTools(state.previousTools);
  } else {
    ctx.ui.notify("Readonly off, but no toolset snapshot was found. Restart the session to restore tools.", "warning");
  }

  state.active = false;
  state.previousTools = [];
  pi.appendEntry(STATE_TYPE, { mode: "off" });
  ctx.ui.setStatus(STATUS_KEY, undefined);
  ctx.ui.notify("Readonly mode off. Previous toolset restored.", "info");
}

// ─── Rehydrate across resume, switch, branch, and tree ────────────────────
function persistedMode(ctx: ExtensionContext): { mode: string; previousTools: string[] } | null {
  let latest: { mode: string; previousTools: string[] } | null = null;
  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type !== "custom" || entry.customType !== STATE_TYPE) continue;
    const data = entry.data as { mode?: unknown; previousTools?: unknown } | undefined;
    if (typeof data?.mode !== "string") continue;
    latest = {
      mode: data.mode,
      previousTools: Array.isArray(data.previousTools) ? (data.previousTools as string[]) : [],
    };
  }
  return latest;
}

async function rehydrate(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
  const state = stateFor(ctx);
  const persisted = persistedMode(ctx);
  const shouldBeActive = persisted?.mode === "on";
  if (!shouldBeActive) {
    state.active = false;
    state.previousTools = [];
    ctx.ui.setStatus(STATUS_KEY, undefined);
    return;
  }
  state.active = true;
  state.previousTools = persisted?.previousTools ?? [];
  await pi.setActiveTools(targetTools(pi));
  ctx.ui.setStatus(STATUS_KEY, "Readonly");
}

export default function readonlyMode(pi: ExtensionAPI): void {
  pi.setLabel("Readonly mode");

  // ─── Slash command ───────────────────────────────────────────────────────
  pi.registerCommand("readonly", {
    description: "Toggle read-only research mode (minimal toolset, scout delegation, no edits)",
    getArgumentCompletions(argumentPrefix) {
      if (argumentPrefix.includes(" ")) return null;
      const items = [
        { label: "on", value: "on", description: "Enter read-only mode" },
        { label: "off", value: "off", description: "Leave read-only mode" },
        { label: "status", value: "status", description: "Show read-only mode state" },
      ];
      const normalized = argumentPrefix.trim().toLowerCase();
      const matches = normalized ? items.filter((item) => item.value.startsWith(normalized)) : items;
      return matches.length > 0 ? matches : null;
    },
    handler: async (args: string, ctx: ExtensionCommandContext) => {
      const arg = args.trim().toLowerCase();
      if (arg === "") {
        const state = stateFor(ctx);
        if (state.active) await exit(pi, ctx);
        else await enter(pi, ctx);
        return;
      }
      if (arg === "on") return enter(pi, ctx);
      if (arg === "off") return exit(pi, ctx);
      if (arg === "status") {
        const state = stateFor(ctx);
        if (state.active) ctx.ui.notify(`Readonly mode: on. Tools: ${pi.getActiveTools().join(", ")}.`, "info");
        else ctx.ui.notify("Readonly mode: off.", "info");
        return;
      }
      ctx.ui.notify(USAGE, "warning");
    },
  });

  // ─── System prompt replacement ─────────────────────────────────────────
  // Returning nothing when the mode is off is correct: the core clears the
  // override and restores the normal prompt automatically.
  pi.on("before_agent_start", async (_event, ctx) => {
    if (!stateFor(ctx).active) return;
    const appended = appendSystemText(pi);
    return { systemPrompt: appended ? [READONLY_PROMPT, appended] : [READONLY_PROMPT] };
  });

  // ─── Fail-closed tool guard ─────────────────────────────────────────────
  pi.on("tool_call", async (event, ctx) => {
    const state = stateFor(ctx);
    if (!state.active) return;

    if (!READONLY_TOOLS.includes(event.toolName)) {
      return {
        block: true,
        reason: `readonly mode: '${event.toolName}' is not available. Run /readonly off to leave read-only mode.`,
      };
    }

    if (event.toolName !== "task") return;

    // An omitted `agent` on a task resolves to the write-capable default, so
    // a missing/blank agent is treated as `"task"` and blocked, forcing an
    // explicit `agent: "scout"`.
    const tasks = (event.input as { tasks?: { agent?: string }[] }).tasks ?? [];
    const rejected = tasks
      .map((task) => task.agent?.trim() || "task")
      .filter((agent) => !ALLOWED_AGENTS.has(agent));
    if (rejected.length > 0) {
      return {
        block: true,
        reason: `readonly mode: only the 'scout' agent may be spawned. Rejected: ${[...new Set(rejected)].join(", ")}. Set agent: "scout" on every task.`,
      };
    }
  });

  // ─── Rehydrate across resume, switch, branch, and tree ─────────────────
  pi.on("session_start", (_event, ctx) => rehydrate(pi, ctx));
  pi.on("session_switch", (_event, ctx) => rehydrate(pi, ctx));
  pi.on("session_branch", (_event, ctx) => rehydrate(pi, ctx));
  pi.on("session_tree", (_event, ctx) => rehydrate(pi, ctx));
  pi.on("session_shutdown", (_event, ctx) => {
    states.delete(ctx.sessionManager.getSessionId());
  });
}
