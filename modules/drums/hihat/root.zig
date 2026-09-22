const std = @import("std");

pub const Hihat = @import("./hihat.zig");

test {
    std.testing.refAllDecls(@This());
}
