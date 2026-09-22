const std = @import("std");

pub const Drone = @import("./drone.zig");

test {
    std.testing.refAllDecls(@This());
}
