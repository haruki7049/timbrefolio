______________________________________________________________________

## name: pr-workflow description: >- Use this skill when creating commits, preparing Pull Requests (PRs), formatting code, and executing pre-submission verification steps for timbrefolio.

# Pull Request & Commit Workflow for `timbrefolio`

This skill defines the procedures for code verification, commit creation, and pull request submission.

## 1. Mandatory Verification Steps

Before committing or opening a PR, execute the following commands and ensure all pass cleanly:

| Task | Command | Description |
| :--- | :--- | :--- |
| **Check All Formatting (treefmt)** | `treefmt --fail-on-change` | Verifies formatting across Nix, Markdown, Zig, and Shell files |
| **Format All Files (treefmt)** | `treefmt` | Auto-formats all files in the repository using treefmt |
| **Run All Tests** | `zig build test` | Executes unit tests for instrument set modules |
| **Build** | `zig build` | Compiles the project |

## 2. Commit & PR Title Conventions

Use Conventional Commits style prefixes:

- `feat:` New instrument, module, or major capability.
- `fix:` Bug fixes or corrections to build or synthesis logic.
- `build:` Updates to `build.zig`, `build.zig.zon`, `flake.nix`, or dependencies (`lightmix`).
- `refactor:` Code restructuring without changing output logic.
- `docs:` Updates to README, AGENTS.md, or code documentation.
- `test:` Adding or updating unit/integration tests.

**Do NOT include issue numbers (e.g., `(#24)` or `#24`) anywhere in commit messages (summary or body) or PR titles.** Issue linkage must be done exclusively in the PR Description using explicit issue-closing keywords (e.g. `Closes #24`). Squash merges copy every commit message into `main`, so a closing keyword in a commit body can close the wrong issue. The ` (#N)` suffix GitHub itself appends to squash-merge summaries is the only exception.

**Language**: Write all commit messages, PR titles, PR descriptions, and repository documentation strictly in English. Never use Japanese or any other non-English language.

## 3. PR Description Requirements

Ensure the PR description includes:

- **Summary**: Concise overview of changes.
- **Linked Issue / Closes Statement**: Always include an explicit issue-closing keyword (e.g. `Closes #16`, `Fixes #12`, or `Resolves #5`) when resolving an open issue.
- **Verification**: Explicitly list executed verification commands (`treefmt --fail-on-change`, `zig build test`) and their success status.
- **Breaking Changes**: Highlight any breaking changes to modules or dependencies.

## 4. Strict Safety & Approval Rules

- **A change request implies commit, push and PR**: When the user instructs a change, carry it through to a pull request without asking for confirmation: work on a topic branch created from the latest `origin/main` (or the existing topic branch for that work; never commit on `main`, since it cannot be pushed), pass the verification commands, then `git commit`, `git push` the topic branch, and open a PR with `gh pr create` if none exists. If the branch already has an open PR, push to it and update the PR description when it has become stale.
- **`main` is protected on GitHub (ruleset active)**: A GitHub ruleset enforces PR-only merges into `main` and also blocks deletion, non-fast-forward pushes, and unsigned commits, and requires linear history. `git push origin main` will therefore be rejected — publishing anything means pushing a topic branch and opening a PR instead. Agents may push that topic branch without seeking confirmation when instructed by the user or when creating or updating a pull request. AI agents **MUST NEVER** merge PRs (including enabling auto-merge with `gh pr merge --auto`) or execute `git merge` autonomously.
- **NEVER PROPOSE COMMITS OR PUSHES UNPROMPTED**: AI agents **MUST NEVER** prompt the user to commit or push unprompted. When instructed by the user or when preparing pull requests on topic branches, agents may execute `git commit` and `git push` directly.
- **Mandatory Human Approval**: AI agents may create branches, create commits, push topic branches, propose PRs, format code, and run test suites, but the final action of merging changes into `main` rests strictly with the human maintainer.
