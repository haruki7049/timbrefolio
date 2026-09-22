const std = @import("std");

pub const Pluck = @import("./pluck.zig");

test {
    std.testing.refAllDecls(@This());
}
