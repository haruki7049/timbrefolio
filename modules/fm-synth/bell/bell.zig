//! Bell-like FM synthesizer voice: two-operator phase modulation shaped by
//! an exponential decay envelope.

const std = @import("std");
const lightmix = @import("lightmix");

/// Synthesis configuration options for the bell generator.
pub fn Options(comptime T: type) type {
    return struct {
        /// Modulator-to-carrier frequency ratio; non-integer values give an inharmonic, bell-like timbre (default: 3.5).
        ratio: T = 3.5,
        /// Phase modulation index / depth (default: 2.0).
        mod_index: T = 2.0,
        /// Exponential amplitude decay factor (default: 3.0).
        decay_rate: T = 3.0,
    };
}

/// Generates a Wave struct containing a synthesized bell tone.
pub fn gen(
    comptime T: type,
    allocator: std.mem.Allocator,
    frequency: T,
    sample_rate: u32,
    channels: u16,
    length: usize,
    volume: T,
    options: Options(T),
) !lightmix.Wave(T) {
    const samples = try array(T, allocator, frequency, sample_rate, channels, length, volume, options);

    return lightmix.Wave(T){
        .allocator = allocator,
        .samples = samples,
        .sample_rate = sample_rate,
        .channels = channels,
    };
}

/// Generates raw sample buffer containing a synthesized bell tone.
pub fn array(
    comptime T: type,
    allocator: std.mem.Allocator,
    frequency: T,
    sample_rate: u32,
    channels: u16,
    length: usize,
    volume: T,
    options: Options(T),
) ![]T {
    var samples = try allocator.alloc(T, length * channels);
    const w_carrier: T = 2.0 * std.math.pi * frequency;
    const w_modulator: T = 2.0 * std.math.pi * frequency * options.ratio;

    for (0..samples.len / channels) |i| {
        const t: T = @as(T, @floatFromInt(i)) / @as(T, @floatFromInt(sample_rate));
        const env: T = std.math.exp(-options.decay_rate * t);
        const modulator: T = options.mod_index * @sin(w_modulator * t);
        const value: T = @sin(w_carrier * t + modulator) * env * volume;

        for (0..channels) |j| {
            samples[i * channels + j] = value;
        }
    }

    return samples;
}

test {
    std.testing.refAllDecls(@This());
}

test "array function produces the expected buffer shape" {
    const allocator = std.testing.allocator;
    const actual = try array(f64, allocator, 440.0, 44100, 1, 10, 1.0, .{});
    defer allocator.free(actual);

    try std.testing.expectEqual(@as(usize, 10), actual.len);
    try std.testing.expectEqual(@as(f64, 0.0), actual[0]);
}

test "gen function supports multi-channel stereo" {
    const allocator = std.testing.allocator;
    const channels: u16 = 2;
    const length: usize = 12;
    var wave = try gen(f64, allocator, 440.0, 44100, channels, length, 0.7, .{});
    defer wave.deinit();

    try std.testing.expectEqual(channels, wave.channels);
    try std.testing.expectEqual(length * channels, wave.samples.len);
    for (0..length) |i| {
        try std.testing.expectEqual(wave.samples[i * channels], wave.samples[i * channels + 1]);
    }
}
