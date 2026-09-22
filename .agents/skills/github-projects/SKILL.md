______________________________________________________________________

## name: github-projects description: Procedures and rules for inspecting, adding, and updating items in GitHub Projects (Projects v2) via the GitHub CLI (gh project).

# GitHub Projects Workflow (`gh project`)

This skill defines instructions and operational invariants for managing GitHub Projects (Projects v2) items, issues, and pull requests via the GitHub CLI.

## 1. Core Invariants & Caveats

### Single-Field Update Per Invocation

The `gh project item-edit` command updates **only a single field per invocation**.

- **NEVER pass multiple `--field` and `--value` pairs in a single command.** The CLI parser (Cobra/pflag) does not treat them as key-value pairs; subsequent flags overwrite previous flags, causing all earlier fields to be silently dropped without error.
- When updating multiple fields (e.g. Priority, Estimate, Size), run separate `gh project item-edit` commands sequentially.

### Discover the Project Number First

`timbrefolio` does not have a dedicated project number hardcoded anywhere. Never guess it:

```bash
gh project list --owner haruki7049
```

Find the project relevant to `timbrefolio` (or ask the user which one to use) before running any `item-edit` commands.

### Schema Discovery Before Modification (Evidence First)

Never guess field names, field types, or select option values:

- Inspect project fields and option definitions first:
  ```bash
  gh project field-list <project-number> --owner <owner> --format json
  ```
- Check existing items and their current field values:
  ```bash
  gh project item-list <project-number> --owner <owner> --format json
  ```

### Verify Project Field Data Types

- **SingleSelect fields** (`ProjectV2SingleSelectField`):
  - Values must match one of the exact defined option names (e.g. `P0`, `P1`, `P2` for `Priority`, not `High`/`Medium`/`Low`).
- **Number fields** (`ProjectV2Field` where type is number):
  - Note exact field naming (e.g. singular `Estimate`, not `Estimates`).
  - Pass the numeric value string (e.g. `--value "3"`).

### Explicit Milestone Assignment Only

AI agents **MUST NEVER** automatically attach or set GitHub Milestones on Pull Requests or Issues unless explicitly requested or instructed by the user.

## 2. Command Examples

### Updating Multiple Fields for an Issue or PR

Execute one invocation per field:

```bash
OWNER="haruki7049"
PROJECT_NUM="<discovered-project-number>"
URL="https://github.com/haruki7049/timbrefolio/issues/1"

# 1. Update Priority
gh project item-edit "$PROJECT_NUM" --owner "$OWNER" --url "$URL" --field "Priority" --value "P1"

# 2. Update Estimate (singular)
gh project item-edit "$PROJECT_NUM" --owner "$OWNER" --url "$URL" --field "Estimate" --value "3"

# 3. Update Size
gh project item-edit "$PROJECT_NUM" --owner "$OWNER" --url "$URL" --field "Size" --value "M"
```

### Batch Updating Multiple Items

```bash
OWNER="haruki7049"
PROJECT_NUM="<discovered-project-number>"

# Table: <URL> <Priority> <Estimate> <Size>
items=(
  "https://github.com/haruki7049/timbrefolio/issues/1 P1 3 M"
  "https://github.com/haruki7049/timbrefolio/pull/2   P0 5 L"
)

for item in "${items[@]}"; do
  read -r url priority estimate size <<< "$item"
  gh project item-edit "$PROJECT_NUM" --owner "$OWNER" --url "$url" --field "Priority" --value "$priority"
  gh project item-edit "$PROJECT_NUM" --owner "$OWNER" --url "$url" --field "Estimate" --value "$estimate"
  gh project item-edit "$PROJECT_NUM" --owner "$OWNER" --url "$url" --field "Size"     --value "$size"
done
```

## 3. Post-Update Verification

Always verify that updates were properly applied:

```bash
gh project item-list <project-number> --owner <owner> --format json
```
