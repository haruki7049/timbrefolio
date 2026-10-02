//! Drum and percussion instrument set.
//!
//! Every instrument is a file struct with a `gen` function that returns a
//! `lightmix.Wave(T)`. All instruments in this genre are unpitched (no
//! `frequency` argument):
//! `gen(T, allocator, sample_rate, channels, length, volume, options)`.
//!
//! A new instrument follows this shape.

const std = @import("std");

pub const closed_hihat = @import("./closed-hihat/root.zig");
pub const hihat = @import("./hihat/root.zig");
pub const kick = @import("./kick/root.zig");
pub const open_hihat = @import("./open-hihat/root.zig");
pub const snare = @import("./snare/root.zig");
pub const tom = @import("./tom/root.zig");

test {
    std.testing.refAllDecls(@This());
}
