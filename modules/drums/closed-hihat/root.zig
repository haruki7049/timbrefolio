const std = @import("std");

pub const ClosedHihat = @import("./closed_hihat.zig");

test {
    std.testing.refAllDecls(@This());
}
