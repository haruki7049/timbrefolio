//! Instrument set aggregator for timbrefolio.
//!
//! Re-exports each genre's instrument set as a snake_case namespace. See
//! each genre's root.zig doc comment for its pitched/unpitched family
//! signature.

const std = @import("std");

pub const analog_synth = @import("analog_synth");
pub const drums = @import("drums");
pub const fm_synth = @import("fm_synth");
pub const ambient = @import("ambient");

test {
    std.testing.refAllDecls(@This());
}
