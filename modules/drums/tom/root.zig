const std = @import("std");

pub const Tom = @import("./tom.zig");

test {
    std.testing.refAllDecls(@This());
}
