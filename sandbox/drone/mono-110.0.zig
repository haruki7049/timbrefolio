const std = @import("std");
const lightmix = @import("lightmix");
const ambient = @import("ambient");

const T = f64;
const Drone = ambient.drone.Drone;

pub fn gen(init: std.process.Init) !lightmix.Wave(T) {
    const allocator: std.mem.Allocator = init.arena.allocator();
    const FREQUENCY: T = 110.0;
    const SAMPLE_RATE: u32 = 44100;
    const CHANNELS: u16 = 1;
    const LENGTH: usize = SAMPLE_RATE * 4;
    const VOLUME: T = 1.0;

    return try Drone.gen(T, allocator, FREQUENCY, SAMPLE_RATE, CHANNELS, LENGTH, VOLUME, .{});
}
