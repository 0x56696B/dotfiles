/**
 * orbit-responses.ts
 *
 * Orbit's Responses API endpoint (backed by AWS Bedrock) strictly requires
 * `type: "message"` on every message input item. It also rejects replayed
 * reasoning items that have no ID, treating each missing ID as the same empty
 * string. OMP emits the required message type only through this hook and may
 * replay opaque reasoning items returned by the gateway.
 *
 * This extension injects `type: "message"` for messages and removes only
 * `type: "reasoning"` items from replayed input. The latter is a provider
 * compatibility workaround: opaque encrypted reasoning cannot safely receive
 * synthetic IDs. When OMP exposes `compat.filterReasoningHistory` in the user
 * models schema, replace this filtering with that declarative setting.
 *
 * Scope: only activates for the `orbit` provider.
 */

import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

const ORBIT_PROVIDER = "orbit";

function prepareOrbitInput(input: unknown): unknown {
  if (!Array.isArray(input)) return input;

  let result: unknown[] | undefined;
  for (let index = 0; index < input.length; index++) {
    const item = input[index];
    const isObject = item !== null && typeof item === "object" && !Array.isArray(item);
    const record = isObject ? (item as Record<string, unknown>) : undefined;

    if (record?.type === "reasoning") {
      result ??= input.slice(0, index);
      continue;
    }

    const prepared = record && "role" in record && !("type" in record) ? { type: "message", ...record } : item;
    if (prepared !== item) result ??= input.slice(0, index);
    result?.push(prepared);
  }

  return result ?? input;
}

export default function orbitResponses(pi: ExtensionAPI) {
  pi.setLabel("Orbit Responses fix");
  pi.on("before_provider_request", async (event, ctx) => {
    if (ctx.model?.provider !== ORBIT_PROVIDER || ctx.model.api !== "openai-responses") return undefined;

    const payload = event.payload;
    if (payload === null || typeof payload !== "object" || Array.isArray(payload)) {
      return undefined;
    }

    const params = payload as Record<string, unknown>;
    if (!Array.isArray(params.input)) return undefined;

    const fixed = prepareOrbitInput(params.input);
    if (fixed === params.input) return undefined;

    return { ...params, input: fixed };
  });
}
