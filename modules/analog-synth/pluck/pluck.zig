//! Plucked subtractive-synth voice: sawtooth oscillator through a one-pole
//! low-pass filter, shaped by an exponential decay envelope.

const std = @import("std");
const lightmix = @import("lightmix");

/// Synthesis configuration options for the pluck generator.
pub fn Options(comptime T: type) type {
    return struct {
        /// Exponential amplitude decay factor (default: 8.0).
        decay_rate: T = 8.0,
        /// One-pole low-pass cutoff in Hz shaping the raw sawtooth; must be > 0 (default: 1800.0).
        cutoff_hz: T = 1800.0,
    };
}

/// Generates a Wave struct containing a synthesized pluck.
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

/// Generates raw sample buffer containing a synthesized pluck.
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

    const dt: T = 1.0 / @as(T, @floatFromInt(sample_rate));
    const rc: T = 1.0 / (2.0 * std.math.pi * options.cutoff_hz);
    const alpha: T = dt / (rc + dt);
    var filtered: T = 0.0;

    for (0..samples.len / channels) |i| {
        const t: T = @as(T, @floatFromInt(i)) * dt;
        const env: T = std.math.exp(-options.decay_rate * t);
        const phase: T = frequency * t;
        const raw: T = 2.0 * (phase - @floor(phase + 0.5));
        filtered = filtered + alpha * (raw - filtered);
        const value: T = filtered * env * volume;

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
    const actual = try array(f64, allocator, 220.0, 44100, 1, 10, 1.0, .{});
    defer allocator.free(actual);

    try std.testing.expectEqual(@as(usize, 10), actual.len);
    try std.testing.expectEqual(@as(f64, 0.0), actual[0]);
}

test "gen function supports multi-channel stereo" {
    const allocator = std.testing.allocator;
    const channels: u16 = 2;
    const length: usize = 12;
    var wave = try gen(f64, allocator, 220.0, 44100, channels, length, 0.7, .{});
    defer wave.deinit();

    try std.testing.expectEqual(channels, wave.channels);
    try std.testing.expectEqual(length * channels, wave.samples.len);
    for (0..length) |i| {
        try std.testing.expectEqual(wave.samples[i * channels], wave.samples[i * channels + 1]);
    }
}

test "envelope decays toward zero over time" {
    const allocator = std.testing.allocator;
    const length: usize = 44100;
    const actual = try array(f64, allocator, 220.0, 44100, 1, length, 1.0, .{});
    defer allocator.free(actual);

    try std.testing.expect(@abs(actual[length - 1]) < 0.01);
}
