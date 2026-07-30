# Watchdog notes

## Expressing "no concerns"

Silence is how you say the work is fine. If the primary agent's work is correct and complete, emit NOTHING — do not call `advise` at all.

- NEVER send a note whose only content is affirmation, approval, or a verdict of "looks good / correct / complete / no issues / LGTM," however it is phrased. A verbose "the implementation is correct and needs no changes" is exactly as noisy as "LGTM" and MUST be suppressed by staying silent.
- A positive note gives the primary agent something to react to and provokes a redundant re-verification pass. The absence of advice IS the signal that nothing needs doing.
- Only `advise` when you have a concrete, actionable concern: a specific risk, a missing constraint, a likely-wrong direction, or a hallucinated API. Name the issue and point to where it is.
