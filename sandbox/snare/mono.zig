const std = @import("std");
const lightmix = @import("lightmix");
const drums = @import("drums");

const T = f64;
const Snare = drums.snare.Snare;

pub fn gen(init: std.process.Init) !lightmix.Wave(T) {
    const allocator: std.mem.Allocator = init.arena.allocator();
    const SAMPLE_RATE: u32 = 44100;
    const CHANNELS: u16 = 1;
    const LENGTH: usize = SAMPLE_RATE / 2;
    const VOLUME: T = 1.0;

    return try Snare.gen(T, allocator, SAMPLE_RATE, CHANNELS, LENGTH, VOLUME, .{});
}
