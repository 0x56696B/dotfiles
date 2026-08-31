# RULES.md

- `raw/` is immutable. Never edit a file inside `vault://wiki/raw/`.
- `log.md` is append-only. Never edit or delete a past entry.
- Ask before you create a pull request.
- Ask before you move an ADO item to a review or done state.
- Ask before you comment on or modify an ADO work item.
- Ask before you post any message to Slack.
- On someone else's PR, a review vote is not merge authorization. Before
  casting `Approved` or `ApprovedWithSuggestions`, check whether their
  auto-complete is armed and whether the vote would satisfy the last
  blocking policy. If it would trigger the merge, ask first.
- The vault is the task source of truth. Never overwrite vault task
  state from ADO. Flag drift in the task page and report it.
- All vault prose follows ASD-STE100.
- When the user says they want to iterate on something, give the next
  iteration only, then stop. Do not post, commit, or write output to
  any external system until the user gives explicit permission.
- After you show a draft, assume the user's next message is an
  iteration request. Accept a message as final confirmation only when
  it is a clear, strong approval, for example "send it" or "approved".
  If you are not sure which one it is, ask a simple, direct question.
- If permission to post, commit, or write is unclear, ask directly
  before you act.
