const std = @import("std");

pub const Kick = @import("./kick.zig");

test {
    std.testing.refAllDecls(@This());
}
