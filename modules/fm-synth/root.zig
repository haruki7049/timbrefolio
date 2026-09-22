//! FM (frequency/phase modulation) synthesizer instrument set.
//!
//! Every instrument is a file struct with a `gen` function that returns a
//! `lightmix.Wave(T)`. All instruments in this genre are pitched:
//! `gen(T, allocator, frequency, sample_rate, channels, length, volume, options)`.
//!
//! A new instrument follows this shape.

const std = @import("std");

pub const bell = @import("./bell/root.zig");

test {
    std.testing.refAllDecls(@This());
}
