//! Closed hi-hat generator: six detuned square waves at inharmonic ratios
//! (the classic analog drum machine cymbal bank) through two cascaded
//! one-pole high-pass filters, shaped by a very fast exponential decay.

const std = @import("std");
const lightmix = @import("lightmix");

/// Base square wave frequencies in Hz of the metallic oscillator bank, scaled by `Options.tuning`.
const metal_frequencies = [_]comptime_float{ 205.3, 304.4, 369.6, 522.7, 540.0, 800.0 };

/// Synthesis configuration options for the closed hi-hat generator.
pub fn Options(comptime T: type) type {
    return struct {
        /// Exponential amplitude decay factor (default: 60.0).
        decay_rate: T = 60.0,
        /// Cutoff in Hz of the two cascaded one-pole high-pass filters; must be > 0 (default: 7000.0).
        cutoff_hz: T = 7000.0,
        /// Multiplier applied to every oscillator frequency in the metallic bank (default: 1.0).
        tuning: T = 1.0,
    };
}

/// Generates a Wave struct containing a synthesized closed hi-hat hit.
pub fn gen(
    comptime T: type,
    allocator: std.mem.Allocator,
    sample_rate: u32,
    channels: u16,
    length: usize,
    volume: T,
    options: Options(T),
) !lightmix.Wave(T) {
    const samples = try array(T, allocator, sample_rate, channels, length, volume, options);

    return lightmix.Wave(T){
        .allocator = allocator,
        .samples = samples,
        .sample_rate = sample_rate,
        .channels = channels,
    };
}

/// Generates raw sample buffer containing a synthesized closed hi-hat hit.
pub fn array(
    comptime T: type,
    allocator: std.mem.Allocator,
    sample_rate: u32,
    channels: u16,
    length: usize,
    volume: T,
    options: Options(T),
) ![]T {
    var samples = try allocator.alloc(T, length * channels);

    const dt: T = 1.0 / @as(T, @floatFromInt(sample_rate));
    const rc: T = 1.0 / (2.0 * std.math.pi * options.cutoff_hz);
    const alpha: T = rc / (rc + dt);
    var prev_metal: T = 0.0;
    var stage1: T = 0.0;
    var prev_stage1: T = 0.0;
    var stage2: T = 0.0;

    for (0..samples.len / channels) |i| {
        const t: T = @as(T, @floatFromInt(i)) * dt;

        var metal: T = 0.0;
        inline for (metal_frequencies) |frequency| {
            const phase: T = frequency * options.tuning * t;
            metal += if (phase - @floor(phase) < 0.5) 1.0 else -1.0;
        }
        metal /= @as(T, @floatFromInt(metal_frequencies.len));

        stage1 = alpha * (stage1 + metal - prev_metal);
        prev_metal = metal;
        stage2 = alpha * (stage2 + stage1 - prev_stage1);
        prev_stage1 = stage1;

        const env: T = std.math.exp(-options.decay_rate * t);
        const value: T = stage2 * env * volume;

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
    const actual = try array(f64, allocator, 44100, 1, 100, 1.0, .{});
    defer allocator.free(actual);

    try std.testing.expectEqual(@as(usize, 100), actual.len);
}

test "gen function supports multi-channel stereo" {
    const allocator = std.testing.allocator;
    const channels: u16 = 2;
    const length: usize = 64;
    var wave = try gen(f64, allocator, 44100, channels, length, 0.8, .{});
    defer wave.deinit();

    try std.testing.expectEqual(channels, wave.channels);
    try std.testing.expectEqual(length * channels, wave.samples.len);
    for (0..length) |i| {
        try std.testing.expectEqual(wave.samples[i * channels], wave.samples[i * channels + 1]);
    }
}

test "output stays within volume and decays toward zero" {
    const allocator = std.testing.allocator;
    const length: usize = 44100 / 2;
    const volume: f64 = 0.9;
    const actual = try array(f64, allocator, 44100, 1, length, volume, .{});
    defer allocator.free(actual);

    for (actual) |sample| {
        try std.testing.expect(@abs(sample) <= volume);
    }
    try std.testing.expect(@abs(actual[length - 1]) < 0.01);
}

test "output is deterministic across calls" {
    const allocator = std.testing.allocator;
    const run1 = try array(f64, allocator, 44100, 1, 200, 0.5, .{});
    defer allocator.free(run1);

    const run2 = try array(f64, allocator, 44100, 1, 200, 0.5, .{});
    defer allocator.free(run2);

    try std.testing.expectEqualSlices(f64, run1, run2);
}
