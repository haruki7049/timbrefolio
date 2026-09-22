const std = @import("std");
const lightmix = @import("lightmix");
const fm_synth = @import("fm_synth");

const T = f64;
const Bell = fm_synth.bell.Bell;

pub fn gen(init: std.process.Init) !lightmix.Wave(T) {
    const allocator: std.mem.Allocator = init.arena.allocator();
    const FREQUENCY: T = 440.0;
    const SAMPLE_RATE: u32 = 44100;
    const CHANNELS: u16 = 1;
    const LENGTH: usize = SAMPLE_RATE * 3;
    const VOLUME: T = 1.0;

    return try Bell.gen(T, allocator, FREQUENCY, SAMPLE_RATE, CHANNELS, LENGTH, VOLUME, .{});
}
