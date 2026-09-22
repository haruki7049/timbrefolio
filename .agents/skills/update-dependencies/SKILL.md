______________________________________________________________________

## name: update-dependencies description: >- Use this skill when adding or updating external Zig package dependencies (such as lightmix), synchronizing Nix lockfiles (.deps.nix via zon2nix), or modifying build.zig.zon.

# External Dependency Update Workflow (`lightmix`)

This workflow applies once `build.zig.zon` exists in this repository. When adding or updating external dependencies such as `lightmix`, both `build.zig.zon` and `.deps.nix` must be kept in sync:

1. **Update `build.zig.zon`**: Add or update the `url` (and package hash) under `.dependencies.lightmix`.
1. **Synchronize Nix Lockfile**: Run `zon2nix > .deps.nix` to regenerate the Nix dependency lockfile `.deps.nix`. (`zon2nix` is already provided by the `nativeBuildInputs` in `flake.nix`.)
1. **Format Code**: Run `treefmt` to format all changed files (including `.deps.nix` and `build.zig.zon`).
1. **Verification**: Run `zig build` and `zig build test` to guarantee error-free compilation and execution.
