const std = @import("std");

pub const OpenHihat = @import("./open_hihat.zig");

test {
    std.testing.refAllDecls(@This());
}
