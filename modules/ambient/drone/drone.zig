//! Ambient pad voice: three detuned sine partials shaped by an
//! attack/release trapezoid envelope (sustains rather than plucks).

const std = @import("std");
const lightmix = @import("lightmix");

/// Synthesis configuration options for the drone generator.
pub fn Options(comptime T: type) type {
    return struct {
        /// Fractional relative detune for the upper/lower partials (default: 0.005 = 0.5%).
        detune: T = 0.005,
        /// Linear fade-in seconds; must be > 0 (default: 0.8).
        attack: T = 0.8,
        /// Linear fade-out seconds before the buffer ends; must be > 0 (default: 0.8).
        release: T = 0.8,
    };
}

/// Generates a Wave struct containing a synthesized ambient pad tone.
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

/// Generates raw sample buffer containing a synthesized ambient pad tone.
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

    const w_center: T = 2.0 * std.math.pi * frequency;
    const w_up: T = 2.0 * std.math.pi * frequency * (1.0 + options.detune);
    const w_down: T = 2.0 * std.math.pi * frequency * (1.0 - options.detune);
    const length_sec: T = @as(T, @floatFromInt(length)) / @as(T, @floatFromInt(sample_rate));

    for (0..samples.len / channels) |i| {
        const t: T = @as(T, @floatFromInt(i)) / @as(T, @floatFromInt(sample_rate));
        const attack_env: T = if (t < options.attack) t / options.attack else 1.0;
        const time_left: T = length_sec - t;
        const release_env: T = if (time_left < options.release) time_left / options.release else 1.0;
        const env: T = std.math.clamp(@min(attack_env, release_env), 0.0, 1.0);

        const raw_signal: T = 0.5 * @sin(w_center * t) + 0.25 * @sin(w_up * t) + 0.25 * @sin(w_down * t);
        const value: T = raw_signal * env * volume;

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
    const actual = try array(f64, allocator, 110.0, 44100, 1, 10, 1.0, .{});
    defer allocator.free(actual);

    try std.testing.expectEqual(@as(usize, 10), actual.len);
    try std.testing.expectEqual(@as(f64, 0.0), actual[0]);
}

test "gen function supports multi-channel stereo" {
    const allocator = std.testing.allocator;
    const channels: u16 = 2;
    const length: usize = 12;
    var wave = try gen(f64, allocator, 110.0, 44100, channels, length, 0.7, .{});
    defer wave.deinit();

    try std.testing.expectEqual(channels, wave.channels);
    try std.testing.expectEqual(length * channels, wave.samples.len);
    for (0..length) |i| {
        try std.testing.expectEqual(wave.samples[i * channels], wave.samples[i * channels + 1]);
    }
}

test "fades out toward the end of the buffer" {
    const allocator = std.testing.allocator;
    const length: usize = 44100 * 3;
    const actual = try array(f64, allocator, 110.0, 44100, 1, length, 1.0, .{});
    defer allocator.free(actual);

    try std.testing.expect(@abs(actual[length - 1]) < 0.01);
}
