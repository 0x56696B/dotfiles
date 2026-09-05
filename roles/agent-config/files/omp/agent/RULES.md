# RULES.md

- `raw/` is immutable. Never edit a file inside `vault://wiki/raw/`.
- `log.md` is append-only. Never edit or delete a past entry.
- The vault is the task source of truth. Never overwrite vault task
  state from an external tracker. Flag drift in the task page and
  report it.
- All vault prose follows ASD-STE100.
- Ask before you create a pull request.
- When the user says they want to iterate on something, give the next
  iteration only, then stop. Do not post, commit, or write output to
  any external system until the user gives explicit permission.
- After you show a draft, assume the user's next message is an
  iteration request. Accept a message as final confirmation only when
  it is a clear, strong approval, for example "send it" or "approved".
  If you are not sure which one it is, ask a simple, direct question.
- If permission to post, commit, or write is unclear, ask directly
  before you act.
- Be concise in every response. Give the direct answer first. Do not
  add extra context, hedging, or restated background.
- `.env.local` is yours to manage. Put the exact line
  `# managed-by: omp-agent (non-secret overrides only)` first, and keep
  secrets out of it. Ask the user for any secret value.
- Check that `.env.local` is gitignored before you write it.
- `.env.local` loads automatically in Next.js, Vite, Create React App,
  Rails with dotenv-rails, and Symfony. It is a no-op in Laravel, bare
  Django or python-dotenv, and Docker Compose. In those stacks, ask the
  user where an override belongs.
- A value shown as `*****` is set, and its real value was hidden from
  you. Never write those asterisks into a file, and never guess the
  value behind them. Ask the user for it.
