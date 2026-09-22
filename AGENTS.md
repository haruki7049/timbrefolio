# Agent Guidelines for `timbrefolio`

This document defines core principles, architectural invariants, and non-negotiable safety rules for AI agents working on the `timbrefolio` repository.

______________________________________________________________________

## 1. Project Overview & Architecture

`timbrefolio` is a repository for building instrument sets on top of the [`lightmix`](https://github.com/haruki7049/lightmix) audio synthesis library in Zig.

- **Development Environment**: Managed with Nix, `direnv`, and `nix-direnv` for automated environment isolation. Formatting across all languages is handled via `treefmt`.
- **Target Language Version**: Zig `0.16.0`, matching the toolchain pinned in `flake.nix`. Avoid unnecessary external dependencies to maintain seamless cross-compilation.
- **Current State**: `timbrefolio` is a Zig library package (`build.zig`, `build.zig.zon`, `src/root.zig`) that depends on `lightmix` and exposes one instrument set per genre under `modules/<genre>/`. The public module is registered as `timbrefolio` via `b.addModule` (matching lightmix's own library-package convention, not a final "song" app like `coffee-chan`), so downstream projects consume it with `b.dependency("timbrefolio", .{})`.
- **Genres**: `modules/analog-synth/` (subtractive), `modules/drums/` (percussion, unpitched instruments), `modules/fm-synth/` (FM/phase modulation), `modules/ambient/` (sustained pads, attack/release envelopes instead of decay-only). Each genre directory has its own `root.zig` aggregator; each instrument directory has a `root.zig` (PascalCase File Struct) plus a leaf `.zig` implementing `Options(T)`/`gen`/`array`, following the shape documented in each genre's `root.zig` doc comment. `sandbox/<instrument>/` holds one-off preview modules rendered via `zig build sandbox`.
- **Dependency Convention**: External Zig dependencies (such as `lightmix`) are mirrored into a Nix-fetchable lockfile via `zon2nix`, following the same convention as [`coffee-chan`](https://github.com/haruki7049/coffee-chan). See [`update-dependencies`](.agents/skills/update-dependencies/SKILL.md).

______________________________________________________________________

## 2. Strict Safety & Operational Rules (Always Enforced)

- **Committing on `main` locally is normal**: Once the user instructs a commit, execute `git commit` immediately; do not ask for confirmation.
- **`main` is protected on GitHub (ruleset active)**: A GitHub ruleset enforces PR-only merges into `main` (0 required approvals, but the PR mechanism itself is mandatory) and also blocks deletion, non-fast-forward pushes, and unsigned commits, and requires linear history. `git push origin main` will therefore be rejected — publishing anything means pushing a topic branch and opening a PR instead. AI agents **MUST NEVER** merge PRs or execute `git merge` autonomously.
- **Pushing always needs its own explicit instruction**: A commit instruction does NOT imply push. AI agents **MUST NEVER** push a branch to the remote unless the user explicitly instructs a push in that turn.
- **NEVER PROPOSE COMMITS OR PUSHES UNPROMPTED**: AI agents **MUST NEVER** prompt the user to commit or push, nor propose commit messages unprompted (e.g. do NOT ask "Would you like me to commit and push?").
- **Mandatory Human Approval**: The final action of pushing to the remote or merging changes into `main` rests strictly with the human maintainer's explicit instruction.
- **Verification Before Submitting**: All changes must pass `treefmt --fail-on-change`, `zig build`, and `zig build test`.
- **Conventional Commits**: Use conventional commit prefixes (`feat:`, `fix:`, `refactor:`, `docs:`, `build:`, `test:`).
- **Evidence First**: Base all answers and actions on actual file contents and command output. Never speculate or assume.
- **Non-Destructive**: Never perform irreversible actions (file deletions, hard resets, remote push) without explicit user approval.
- **Targeted Edits**: Make minimal, logical changes strictly necessary for the request. Do not modify unrelated files.
- **English-Only Documentation**: All repository documentation, agent skills, code comments, commit messages, and PR descriptions must be written strictly in English. Never include Japanese or any non-English language in repository documentation or skill files.

______________________________________________________________________

## 3. Status Assessment Workflow

When asked to check status, assess the situation, or understand workspace context:

1. **Local Git State**: Inspect working tree (`git status -s -b`) and recent commits (`git log -n 5 --oneline`).
1. **GitHub PRs**: Check PR status (`gh pr status`) and current PR details (`gh pr view`).
1. **GitHub Issues**: Check relevant open issues (`gh issue list --limit 5`).
1. **Environment Health**: Verify formatting (`treefmt --fail-on-change`) and build/test status (`zig build`, `zig build test`).
1. **Synthesis**: Report a concise, structured status covering local state, remote GitHub state, and environment health.

______________________________________________________________________

## 4. Workspace Skills

Detailed runbooks and procedural workflows are maintained as workspace skills under `.agents/skills/` (and accessible via `.opencode/skills/`):

| Trigger / Context | Skill to Read | Purpose |
| :--- | :--- | :--- |
| Deep investigation, complex code search | [`investigate`](.agents/skills/investigate/SKILL.md) | Non-destructive investigation guidelines |
| Commit conventions & policies | [`git-commit`](.agents/skills/git-commit/SKILL.md) | Commit conventions and prohibition of unprompted commit/push proposals |
| Deleting files, overwriting, git push/reset | [`irreversible`](.agents/skills/irreversible/SKILL.md) | Pre-checks and confirmation prompts |
| Testing, verifying builds or behavior | [`verify`](.agents/skills/verify/SKILL.md) | Minimal, high-signal verification steps |
| Adding or bumping `lightmix` or other Zig dependencies | [`update-dependencies`](.agents/skills/update-dependencies/SKILL.md) | Procedures for dependency updates and `.deps.nix` (once `build.zig.zon` exists) |
| Preparing PRs, formatting, pre-submission checks | [`pr-workflow`](.agents/skills/pr-workflow/SKILL.md) | Verification command table, commit rules, and PR requirements |
