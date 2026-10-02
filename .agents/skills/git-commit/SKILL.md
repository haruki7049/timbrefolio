______________________________________________________________________

## name: git-commit description: Repository commit conventions and prohibition on unprompted commit/push proposals.

# Git Commit Policy & Conventions

Read this to understand the commit policy and message conventions for `timbrefolio`.

## Prohibition on Unprompted Commit/Push Proposals

- **A change request implies commit, push and PR**: When the user instructs a change, carry it through to a pull request without asking for confirmation: work on a topic branch created from the latest `origin/main` (or the existing topic branch for that work; never commit on `main`, since it cannot be pushed), pass the verification commands, then `git commit`, `git push` the topic branch, and open a PR with `gh pr create` if none exists. If the branch already has an open PR, push to it and update the PR description when it has become stale.
- **`main` is protected on GitHub (ruleset active)**: A GitHub ruleset enforces PR-only merges into `main` and also blocks deletion, non-fast-forward pushes, and unsigned commits, and requires linear history. `git push origin main` will therefore be rejected — publishing anything means pushing a topic branch and opening a PR instead. Agents may push that topic branch without seeking confirmation when instructed by the user or when creating or updating a pull request.
- **Do NOT propose or prompt for commits or pushes**: AI agents must never prompt the user to commit or push unprompted, nor ask for confirmation (e.g., do NOT ask "Would you like me to commit and push?").
- **Do NOT include unprompted commit message proposals**: Do NOT append "Proposed commit message" or commit/push suggestion sections at the end of a response unless explicitly asked by the user.

## Commit Message Conventions

When creating a commit or formulating a commit message:

Follow the repository convention (see `.agents/skills/pr-workflow/SKILL.md`):

- Use Conventional Commits style prefixes (`feat:`, `fix:`, `build:`, `refactor:`, `docs:`, `test:`).
- English, imperative mood, short summary, under 72 characters, no trailing period.
- **Do NOT include issue numbers (e.g., `(#24)` or `#24`) anywhere in the commit message — neither the summary nor the body.** Issue linkage must be done exclusively in the PR Description using explicit issue-closing keywords (e.g. `Closes #24`). This matters because squash merges copy every commit message into `main`, so a `Closes #24` in a commit body can close an issue the PR was never meant to close.
- The ` (#N)` suffix GitHub appends to a squash-merge commit's summary (the PR number) is added by GitHub, not by agents, and is the one exception.

Examples:

- `build: add nix-direnv development environment`
- `feat: add first instrument set module`
- `docs: update git commit guidance`
