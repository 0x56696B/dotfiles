---
name: concise-answers-only
description: "Keep chat replies short and direct instead of padding with excess explanation"
condition: ["^.{1200,}", "Here's the (proposed |corrected )?(fix|diff|comment)"]
scope: "text"
---

Answers must be concise. Lead with the direct answer or artifact. Cut restated context, redundant framing sentences, and multi-paragraph preambles before code or diffs. State design choices in a short bullet list, not prose paragraphs. If a diff or comment is requested, show it with minimal surrounding commentary — one or two sentences max, not a walkthrough.