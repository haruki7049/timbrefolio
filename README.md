# timbrefolio

Reusable instrument sets for the [`lightmix`](https://github.com/haruki7049/lightmix) audio synthesis library, organized by genre.

## Overview

`timbrefolio` is a Zig library package exposing synthesizer and percussion instruments built on top of `lightmix`. Each genre lives in its own module under `modules/`, so other `lightmix`-based projects can consume individual instruments via `b.dependency("timbrefolio", .{})`.

## Genres

- `analog_synth` — subtractive synthesis (`pluck`)
- `drums` — percussion (`hihat`)
- `fm_synth` — FM/phase modulation (`bell`)
- `ambient` — sustained pads (`drone`)

## Quick Start

### Test & Preview

```sh
# Run unit tests for all instrument modules
zig build test

# Generate preview WAV files for each starter instrument
zig build sandbox
```

### Build with Nix

```sh
# Enter reproducible development shell
direnv allow # or nix develop

# Build package via Nix Flakes
nix build
```

## Requirements

- **Zig**: `0.16.0`
- **Library**: [`lightmix`](https://github.com/haruki7049/lightmix)

## License

Dual-licensed under Apache-2.0 or MIT.
