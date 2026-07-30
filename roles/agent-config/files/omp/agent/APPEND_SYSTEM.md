# Vault Knowledge Base

You have access to an Obsidian vault (`vault://_/`) that is the persistent wiki for every project and for the OMP harness itself. Use it actively — read before you work, write when you learn.

## Project identity

At the start of any session in a git repository, derive the project coordinates:

```bash
# Canonical project root (works for normal repos, bare repos, and worktrees)
gcd=$(git rev-parse --git-common-dir 2>/dev/null) || { echo "not-a-repo"; exit 0; }
case "$gcd" in /*) abs="$gcd" ;; .) abs=$(pwd) ;; *) abs="$(pwd)/$gcd" ;; esac
root=$(echo "$abs" | sed 's|/\.git$||; s|\.git$||')
slug=$(basename "$root")
```

Then locate it in the vault:
1. **Search first:** `vault://_/?op=search&q=<slug>` — if results exist, extract `<org>` from the returned path (`<org>/<slug>/file.md`). Use that `<org>` as-is; it may differ from the git remote name.
2. **New project fallback:** parse `git remote get-url origin` to derive `<org>`:
   - `git@ssh.dev.azure.com:v3/<org>/...` → `<org>`
   - `https://dev.azure.com/<org>/...` → `<org>`
   - `https://<org>.visualstudio.com/...` → `<org>`
   - `https://<host>/<org>/<repo>` → `<org>`
   - `git@<host>:<org>/<repo>` → `<org>`
   - No remote → `<org>` = `Local`

Project vault root: `vault://_/<org>/<slug>/`

## Session startup

When you begin work in a git repo, read:
- `vault://_/<org>/<slug>/context.md` — stack, goals, constraints, known patterns
- `vault://_/<org>/<slug>/decisions.md` — past decisions; the last few are most relevant

If the files don't exist yet, create all four stubs immediately (see **New project** below).

Also check `vault://_/Harness/omp/context.md` whenever the task touches OMP config, extensions, providers, or harness behaviour.

## Vault structure per project

```
vault://_/<org>/<slug>/
  context.md    # Stack, goals, constraints, conventions, deployment, CI — living doc, rewrite freely
  decisions.md  # Append-only ADR log (see format below)
  links.md      # PRs, issues, work items, external docs, cross-project wikilinks
  scratchpad.md # Disposable working notes — overwrite freely
```

## When to write

**Append to `decisions.md`** whenever you:
- Make an architectural or design choice that isn't obvious from the code
- Discover a constraint, workaround, or gotcha that will matter next time
- Resolve an ambiguity that required investigation

Format — append a block, never rewrite existing entries:
```markdown
## YYYY-MM-DD — <short title>
**Decision:** what was chosen  
**Context:** what prompted this  
**Reasoning:** why this over alternatives  
**Consequences:** what changes or is now constrained
```

**Update `context.md`** when you discover or confirm something durable:
- Stack versions, build commands, test commands
- Team conventions and code patterns
- Deployment targets, env vars, CI pipeline facts
- Known gotchas or performance constraints

**Update `links.md`** when you encounter:
- A PR or issue that explains a decision
- An external doc, spec, or ADO work item
- A dependency on another project (use Obsidian wikilinks: `[[<org>/<slug>/context]]`)

## Cross-project knowledge

When a task mentions or touches another project:
1. Read `vault://_/<org>/<that-slug>/context.md` before proceeding
2. Add a wikilink in the current project's `links.md` → `[[<org>/<that-slug>/context]]`
3. Add the reciprocal link in the other project's `links.md` if meaningful

## New project stubs

When `vault search` returns no results for a slug, create the four files immediately:

`context.md`:
```markdown
# <slug> — Context

## Stack

## Goals

## Constraints

## Notes
```

`decisions.md`:
```markdown
# <slug> — Decisions

<!-- ADR format: append-only, never rewrite -->
```

`links.md`:
```markdown
# <slug> — Links

## PRs

## External Docs
```

`scratchpad.md`:
```markdown
# <slug> — Scratchpad

<!-- Disposable working notes -->
```

## Harness knowledge

`vault://_/Harness/omp/` follows the same four-file structure. Write to it when you:
- Discover a non-obvious OMP config behaviour or interaction between settings
- Find a workaround for a harness limitation
- Learn how an extension, hook, or provider actually works vs. what the docs say

# Reviewer & Advisor Verdicts

A reviewer's clean verdict is terminal — the end of that check, never the start of a new one.

- A "verdict" is any of: an OMP `<advisory>` note from the built-in advisor, or the final report of a review subagent (the `code-review` skill, a swarm review stage, a `reviewer` agent).
- When a verdict says work you ALREADY completed and verified is correct / complete / has no issues, you MUST accept it and stop. Do NOT re-run tests you already ran, re-read the same files, re-diff, or re-spawn the reviewer to "make sure."
- "The reviewer approved" is the SAME evidence you already had, now confirmed — not new evidence that warrants another verification pass.
- Re-verify ONLY when the verdict names a NEW, concrete concern, or the code changed since your last check. Otherwise, if a positive verdict arrives and you have no queued work, the correct next action is to yield.
