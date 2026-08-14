---
name: wiki-meeting
description: Use when the user gives a meeting transcript or notes — a file already in vault/raw/, or pasted text to save there first. Files the meeting, action items as tasks, and attendees as people.
---

## When
Trigger on a meeting transcript, meeting notes, or a standup summary.
Trigger when the user names a meeting file already inside `vault://wiki/raw/`.
Trigger when the user pastes meeting text and asks you to file it.

## Inputs
- A raw file path inside `vault://wiki/raw/`, or pasted meeting text.
- The meeting date, kind, project, and org, from the user or from the raw text.
- The attendee list, from the raw text.

## Steps
1. Identify the entry point: a named raw file, or pasted text.
2. If the user pasted text, build a slug from the meeting topic in kebab-case.
3. Write the pasted text to `vault://wiki/raw/YYYY-MM-DD-<slug>.md`. Use the meeting date.
4. If the user named an existing raw file, read it. Never edit a file in `raw/`.
5. Read the full raw content before you extract facts from it.
6. Pull out the date, the kind, the project, the org, and each attendee.
7. The kind is one of: standup, refinement, planning, one-on-one, or adhoc.
8. For each attendee, check for a page at `vault://wiki/people/<first-last>.md`.
9. If a person page is missing, create it from `vault://wiki/templates/person.md`.
10. Fill the org field on the new person page. Fill the role field if you know it.
11. Create a meeting page at `vault://wiki/meetings/YYYY-MM-DD-<slug>.md` from `vault://wiki/templates/meeting.md`.
12. Fill the frontmatter. See `vault://wiki/schema.md` for the meeting field table.
13. Set `attendees` to a wikilink for each person. Set `raw` to a wikilink to the raw file.
14. Set `created` to today's date. Write the summary and the decisions in the body.
15. Pull out each action item from the raw content.
16. For each action item, create a task page at `vault://wiki/tasks/<slug>.md` from `vault://wiki/templates/task.md`.
17. See `vault://wiki/schema.md` for the task field table.
18. Set `status` to `inbox` on every new task page. Set `priority` to `p3` unless the text states one.
19. Set `project` to a wikilink to the matching project. Add a wikilink to the meeting page in the body.
20. Update the linked project page with a wikilink to the new meeting page.
21. Add entries for the meeting page, the new task pages, and the new person pages to `vault://wiki/index.md`. File them under the Meetings, Tasks, and People headings.
22. Append a log entry to `vault://wiki/log.md`.

## Writes
| Page or file | Fields or content changed |
|---|---|
| `vault://wiki/raw/YYYY-MM-DD-<slug>.md` | created, only for the pasted-text entry point |
| `vault://wiki/meetings/YYYY-MM-DD-<slug>.md` | `type`, `date`, `kind`, `project`, `org`, `attendees`, `raw`, `created`, body |
| `vault://wiki/tasks/<slug>.md` (one per action item) | `type`, `project`, `status: inbox`, `priority`, `created`, body with meeting wikilink |
| `vault://wiki/people/<first-last>.md` (new attendees) | created: `type`, `org`, `role`, `created` |
| `vault://wiki/projects/<name>.md` (linked project) | body: wikilink to the new meeting page |
| `vault://wiki/index.md` | new entries under the Meetings, Tasks, and People headings |
| `vault://wiki/log.md` | one new entry appended |

## Log
Append this entry to `vault://wiki/log.md`:
```
## [YYYY-MM-DD] meeting | <meeting title>
- Filed <meeting title> with <n> attendees and <n> action items.
- New pages: <task pages>, <person pages>.
```
