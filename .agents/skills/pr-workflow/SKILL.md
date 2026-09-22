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

**Do NOT include issue numbers (e.g., `(#24)` or `#24`) in commit messages or PR titles.** Issue linkage must be done exclusively in the PR Description using explicit issue-closing keywords (e.g. `Closes #24`).

**Language**: Write all commit messages, PR titles, PR descriptions, and repository documentation strictly in English. Never use Japanese or any other non-English language.

## 3. PR Description Requirements

Ensure the PR description includes:

- **Summary**: Concise overview of changes.
- **Linked Issue / Closes Statement**: Always include an explicit issue-closing keyword (e.g. `Closes #16`, `Fixes #12`, or `Resolves #5`) when resolving an open issue.
- **Verification**: Explicitly list executed verification commands (`treefmt --fail-on-change`, `zig build test`) and their success status.
- **Breaking Changes**: Highlight any breaking changes to modules or dependencies.

## 4. GitHub Projects Integration

When creating PRs and issues or updating project attributes in GitHub Projects (Projects v2):

- **Assign Project Attributes**: When creating a PR or issue, always assign the `Estimate`, `Priority`, and `Size` fields in GitHub Projects.
- Follow the [`github-projects`](../github-projects/SKILL.md) skill.
- Inspect the project schema (`gh project field-list`) before attempting to set field values.
- Never pass multiple `--field` and `--value` pairs in a single `gh project item-edit` command; invoke the command once per field.
- **Explicit Milestone Assignment Only**: AI agents **MUST NEVER** automatically attach or set GitHub Milestones on Pull Requests or Issues unless explicitly requested or instructed by the user.

## 5. Strict Safety & Approval Rules

- **Committing on `main` locally is normal**: Once instructed, agents may execute `git commit` on `main` directly without seeking confirmation.
- **`main` is protected on GitHub (ruleset active)**: A GitHub ruleset enforces PR-only merges into `main` and also blocks deletion, non-fast-forward pushes, and unsigned commits, and requires linear history. `git push origin main` will therefore be rejected — publishing anything means pushing a topic branch and opening a PR instead, and that push still requires the user's explicit instruction each time; a commit instruction alone does not imply push. AI agents **MUST NEVER** merge PRs or execute `git merge` autonomously.
- **NEVER PROPOSE COMMITS OR PUSHES UNPROMPTED**: AI agents **MUST NEVER** prompt the user to commit or push unprompted.
- **Mandatory Human Approval**: The final action of pushing to the remote or merging changes into `main` rests strictly with the human maintainer's explicit instruction.
