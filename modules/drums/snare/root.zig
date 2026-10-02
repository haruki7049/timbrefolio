const std = @import("std");

pub const Snare = @import("./snare.zig");

test {
    std.testing.refAllDecls(@This());
}
