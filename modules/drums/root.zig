//! Drum and percussion instrument set.
//!
//! Every instrument is a file struct with a `gen` function that returns a
//! `lightmix.Wave(T)`. All instruments in this genre are unpitched (no
//! `frequency` argument):
//! `gen(T, allocator, sample_rate, channels, length, volume, options)`.
//!
//! A new instrument follows this shape.

const std = @import("std");

pub const hihat = @import("./hihat/root.zig");

test {
    std.testing.refAllDecls(@This());
}
