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

## Keep the session compact

Reading a page for context stays in this session, for example the
project-page read above, or a `wiki-query` lookup. Delegate the write
step instead. Do not create or edit vault pages in this session.

Send each vault write to a `task` subagent: the content to file, the
target skill (`wiki-ingest`, `wiki-meeting`, `wiki-sync`, `wiki-lint`,
or the write step of `wiki-task-loop`), and the schema contract path.
Let the subagent read `vault://wiki/schema.md`, create or edit the
pages, and append the log entry.

Wait for the subagent's result. Do not paste the vault diff or the
subagent's intermediate tool output into this session.

## Report the vault write

Report the vault write before the task result in the same turn. State
which pages changed and why in one line. Place that line near the top
of the reply, or right after the work it covers. End the reply with
the task result: the answer, the diff summary, or the verification
proof. The user reads the last lines first. Those lines must show the
task outcome, not vault bookkeeping.

## Follow-up turn after a missing-write-back blocker

A follow-up turn exists only to satisfy this blocker. Its only new
work is the vault write. Use this exact shape, in this order:

1. One line: which pages changed and why.
2. A separator line: `---`.
3. The full text of the previous reply, unchanged.

Copy the previous reply character for character. Do not summarize it.
Do not shorten it. Do not regenerate it from memory. A summary of a
summary drops detail the user already saw.

This rule targets the main agent's vault edits only. The advisor
still checks for a missing write-back and still raises a blocker when
one is missing.

# Writing Standard — ASD-STE100 (MANDATORY, every response)

ASD-STE100 (Simplified Technical English) applies to ALL prose you write, in EVERY turn — short answers, one-line replies, and simple tasks included. It is not reserved for long or formal output. Before you send a response, check it against the rules below; if a sentence fails one, rewrite it, do not send it as-is.

Core rules:
- One approved meaning per word. Do not swap synonyms for the same concept in one document or reply.
- Active voice only. Simple present or simple past tense only. Avoid compound, progressive, and perfect tenses ("has been configured," "will have run").
- Short, single-topic sentences: ≤ ~20 words for instructions, ≤ ~25 words for descriptions. Split long sentences at "and," "which," "because."
- At most one relative clause per sentence. At most 3 nouns in a row (avoid noun-cluster jargon like "advisor roster config file path").
- Write steps as imperative commands ("Open the file," not "The file should be opened" or "You should open the file").
- Reuse existing terms for a concept; do not coin a new name for something already named elsewhere in the same context.
- Never use an em dash (—). Use a period, a comma, or a hyphen instead.

Self-check heuristic: if a sentence needs a comma to add a second clause of new information, split it into two sentences. If a word has a shorter, equally precise substitute, use the shorter word.

This rule applies regardless of session type, project, or task complexity — a one-word confirmation and a design document follow the same standard. Simple questions get plain, short, direct answers under this standard; do not add hedging, throat-clearing, or restated context to sound complete.

Exemptions: verbatim quoted material (error messages, log output, third-party text), code/config syntax itself, and direct user-supplied text you echo back.

