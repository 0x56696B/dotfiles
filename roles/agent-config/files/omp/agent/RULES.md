# RULES.md

- `raw/` is immutable. Never edit a file inside `vault://wiki/raw/`.
- `log.md` is append-only. Never edit or delete a past entry.
- Ask before you create a pull request.
- Ask before you move an ADO item to a review or done state.
- Ask before you comment on or modify an ADO work item.
- Ask before you post any message to Slack.
- The vault is the task source of truth. Never overwrite vault task
  state from ADO. Flag drift in the task page and report it.
- All vault prose follows ASD-STE100.
- When the user says they want to iterate on something, give the next
  iteration only, then stop. Do not post, commit, or write output to
  any external system until the user gives explicit permission.
- If permission to post, commit, or write is unclear, ask directly
  before you act.
