//! Ambient and pad instrument set.
//!
//! Every instrument is a file struct with a `gen` function that returns a
//! `lightmix.Wave(T)`. All instruments in this genre are pitched:
//! `gen(T, allocator, frequency, sample_rate, channels, length, volume, options)`.
//! Unlike percussive genres, envelopes here are attack/release trapezoids
//! rather than decay-only, since ambient instruments are meant to sustain
//! rather than pluck.
//!
//! A new instrument follows this shape.

const std = @import("std");

pub const drone = @import("./drone/root.zig");

test {
    std.testing.refAllDecls(@This());
}
