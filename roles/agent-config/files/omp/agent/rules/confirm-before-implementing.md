---
name: confirm-before-implementing
description: "Pause and ask for explicit user consent before writing or modifying any file when implementation was not clearly requested"
condition: ["(?i)\\bgoing to (?:create|write|edit|modify|implement|build|apply)\\b", "(?i)\\b(?:create|write|edit|modify|implement|generate) the (?:file|config|configuration|script|implementation|solution)\\b"]
scope: "thinking"
---

STOP. You are planning to make file changes. Before proceeding:

- Did the user **explicitly** ask for implementation? Or were they exploring, asking a question, describing a problem, or learning?
- If there is ANY ambiguity — do NOT touch files. Instead:
  1. Describe the proposed approach in prose only.
  2. Ask one clear question: "Should I go ahead and implement this?"
  3. Wait for an explicit affirmative before making any file changes.

Vague requirements, exploratory conversations, and learning sessions are NOT implementation requests. Propose first; implement only after explicit consent.