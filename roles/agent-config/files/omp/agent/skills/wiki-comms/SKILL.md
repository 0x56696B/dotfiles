---
name: wiki-comms
description: Use when the user asks to check Slack, catch up on a channel or thread, search Slack history, or draft and send a Slack message.
---

## When
- The user asks what happened in a channel or thread.
- The user asks the agent to draft a Slack message or reply.
- Another skill (`wiki-task-loop`) asks you to draft a Slack update.

## Inputs
- Org pages under `vault://wiki/orgs/` (`slack_channels` field).
- Slack read routes: `xd://mcp__slack_channels_me`, `xd://mcp__slack_channels_list`, `xd://mcp__slack_conversations_history`, `xd://mcp__slack_conversations_replies`, `xd://mcp__slack_conversations_search_messages`, `xd://mcp__slack_conversations_unreads`, `xd://mcp__slack_users_search`.
- Slack write route (gated): `xd://mcp__slack_conversations_add_message`.

## Steps
1. Find the right channel. Read the org page under `vault://wiki/orgs/` (per `vault://wiki/schema.md`) and take its `slack_channels` list. Cross-check against `xd://mcp__slack_channels_me` for channels the agent can reach.
2. Read for context. Use `xd://mcp__slack_conversations_history` for channel activity, `xd://mcp__slack_conversations_replies` for one thread, and `xd://mcp__slack_conversations_search_messages` for a keyword or person search. Use `xd://mcp__slack_conversations_unreads` to catch up on everything unread.
3. Resolve people. Use `xd://mcp__slack_users_search` to match a Slack user to a page under `vault://wiki/people/`. Create or update the person page with the resolved `slack_id`.
4. Write the draft message and name the target channel or thread. Do not call `xd://mcp__slack_conversations_add_message` before the Gate below passes.
5. GATE. Show the exact draft text and the target channel or thread. Wait for explicit approval.
6. After approval, send the approved text, unedited, with `xd://mcp__slack_conversations_add_message`.
7. File a thread with lasting value: a decision, an announcement, or a spec discussion. Create a source page at `vault://wiki/sources/YYYY-MM-DD-<slug>.md`. Set `type: source`, `origin: slack`, and the thread `url` if one exists. Write a short summary. Link the page from the related project or decision page. Add an entry for the source page to `vault://wiki/index.md`, under the Sources heading.
8. Append the log entry (see `## Log`) to `vault://wiki/log.md`.

## Gates
- Before any call to `xd://mcp__slack_conversations_add_message`: show the exact draft text and the target channel or thread, and wait for approval. Send only the approved text.

## Writes
| Page/file | Fields changed |
|---|---|
| `vault://wiki/people/<first-last>.md` | `slack_id` (new or updated) |
| `vault://wiki/sources/YYYY-MM-DD-<slug>.md` | new page: `type: source`, `date`, `origin: slack`, `url`, `projects` |
| `vault://wiki/index.md` | new entry for the source page, under the Sources heading |
| `vault://wiki/log.md` | appended entry |

## Log
```
## [YYYY-MM-DD] comms | <channel or topic>
- Read <channel/thread> for context; resolved <n> person page(s).
- Drafted and sent update to <channel> after approval. (omit if no send)
- Filed source: [[sources/YYYY-MM-DD-<slug>]]. (omit if none)
```
