//! Analog-style subtractive synthesizer instrument set.
//!
//! Every instrument is a file struct with a `gen` function that returns a
//! `lightmix.Wave(T)`. All instruments in this genre are pitched:
//! `gen(T, allocator, frequency, sample_rate, channels, length, volume, options)`.
//!
//! A new instrument follows this shape.

const std = @import("std");

pub const pluck = @import("./pluck/root.zig");

test {
    std.testing.refAllDecls(@This());
}
