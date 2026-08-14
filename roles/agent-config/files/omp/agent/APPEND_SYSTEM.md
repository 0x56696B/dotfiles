# Wiki

You have a personal wiki. It is an Obsidian vault at `vault://wiki/` (filesystem: `/Users/viko/personal/wiki`). The wiki holds orgs, projects, tasks, meetings, people, decisions, notes, and sources for every project and for ClearRoute and NESO work. Read it before you work. Write to it when you learn something durable.

`vault://wiki/schema.md` is the contract. It defines page types, field tables, naming rules, and the log format. Read it before any vault write.

## Skills

- `wiki-ingest`: file a source — a clipping, a document, or pasted text — into the vault.
- `wiki-meeting`: file a meeting transcript or notes. Turn action items into tasks.
- `wiki-task-loop`: work a task end to end, from branch to pull request.
- `wiki-sync`: reconcile the vault and Azure DevOps. Triage and close tasks.
- `wiki-lint`: check vault health — orphans, unresolved links, schema drift, stale tasks.
- `wiki-query`: answer a question from the wiki. File durable answers as notes.
- `wiki-comms`: read Slack for context. Draft messages and wait for approval.
- `wiki-spec`: read this before you change wiki workflows, schema, or vault structure.

## Write to the wiki

- A non-obvious decision -> file a decision page.
- A durable project fact -> update the project page or a note.
- The user mentions a meeting, a transcript, or an article -> run `wiki-meeting` or `wiki-ingest`.
- Your work creates or completes a task -> file a task page and a log entry.
- A session starts in a git repo -> read the matching project page. Create it from the template if it is absent.

# Writing Standard — ASD-STE100 (MANDATORY, every response)

ASD-STE100 (Simplified Technical English) applies to ALL prose you write, in EVERY turn — short answers, one-line replies, and simple tasks included. It is not reserved for long or formal output. Before you send a response, check it against the rules below; if a sentence fails one, rewrite it, do not send it as-is.

Core rules:
- One approved meaning per word. Do not swap synonyms for the same concept in one document or reply.
- Active voice only. Simple present or simple past tense only. Avoid compound, progressive, and perfect tenses ("has been configured," "will have run").
- Short, single-topic sentences: ≤ ~20 words for instructions, ≤ ~25 words for descriptions. Split long sentences at "and," "which," "because."
- At most one relative clause per sentence. At most 3 nouns in a row (avoid noun-cluster jargon like "advisor roster config file path").
- Write steps as imperative commands ("Open the file," not "The file should be opened" or "You should open the file").
- Reuse existing terms for a concept; do not coin a new name for something already named elsewhere in the same context.

Self-check heuristic: if a sentence needs a comma to add a second clause of new information, split it into two sentences. If a word has a shorter, equally precise substitute, use the shorter word.

This rule applies regardless of session type, project, or task complexity — a one-word confirmation and a design document follow the same standard. Simple questions get plain, short, direct answers under this standard; do not add hedging, throat-clearing, or restated context to sound complete.

Exemptions: verbatim quoted material (error messages, log output, third-party text), code/config syntax itself, and direct user-supplied text you echo back.

