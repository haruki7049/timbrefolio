const std = @import("std");
const lightmix = @import("lightmix");
const analog_synth = @import("analog_synth");

const T = f64;
const Pluck = analog_synth.pluck.Pluck;

pub fn gen(init: std.process.Init) !lightmix.Wave(T) {
    const allocator: std.mem.Allocator = init.arena.allocator();
    const FREQUENCY: T = 220.0;
    const SAMPLE_RATE: u32 = 44100;
    const CHANNELS: u16 = 1;
    const LENGTH: usize = SAMPLE_RATE * 2;
    const VOLUME: T = 1.0;

    return try Pluck.gen(T, allocator, FREQUENCY, SAMPLE_RATE, CHANNELS, LENGTH, VOLUME, .{});
}
