______________________________________________________________________

## name: git-commit description: Repository commit conventions and prohibition on unprompted commit/push proposals.

# Git Commit Policy & Conventions

Read this to understand the commit policy and message conventions for `timbrefolio`.

## Prohibition on Unprompted Commit/Push Proposals

- **Committing on `main` locally is normal**: Once the user instructs a commit, execute `git commit` immediately; do not ask for confirmation.
- **`main` is protected on GitHub (ruleset active)**: A GitHub ruleset enforces PR-only merges into `main` and also blocks deletion, non-fast-forward pushes, and unsigned commits, and requires linear history. `git push origin main` will therefore be rejected — publishing anything means pushing a topic branch and opening a PR instead, and that push still requires the user's explicit instruction each time; a commit instruction alone does not imply push.
- **Do NOT propose or prompt for commits or pushes**: AI agents must never prompt the user to commit or push unprompted, nor ask for confirmation (e.g., do NOT ask "Would you like me to commit and push?").
- **Do NOT include unprompted commit message proposals**: Do NOT append "Proposed commit message" or commit/push suggestion sections at the end of a response unless explicitly asked by the user.

## Commit Message Conventions

When creating a commit or formulating a commit message:

Follow the repository convention (see `.agents/skills/pr-workflow/SKILL.md`):

- Use Conventional Commits style prefixes (`feat:`, `fix:`, `build:`, `refactor:`, `docs:`, `test:`).
- English, imperative mood, short summary, under 72 characters, no trailing period.
- **Do NOT include issue numbers (e.g., `(#24)` or `#24`) in the commit summary.** Issue linkage must be done exclusively in the PR Description using explicit issue-closing keywords (e.g. `Closes #24`).

Examples:

- `build: add nix-direnv development environment`
- `feat: add first instrument set module`
- `docs: update git commit guidance`
