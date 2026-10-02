//! Snare drum generator: a decaying triangle tone for the drum shell mixed
//! with one-pole high-passed white noise for the snare wires, each shaped by
//! its own fast exponential decay.

const std = @import("std");
const lightmix = @import("lightmix");

var prng = std.Random.DefaultPrng.init(0);

/// Resets the internal pseudo-random number generator to its initial deterministic seed.
pub fn reset() void {
    prng = std.Random.DefaultPrng.init(0);
}

/// Synthesis configuration options for the snare generator.
pub fn Options(comptime T: type) type {
    return struct {
        /// Shell tone frequency in Hz (default: 185.0).
        tone_frequency: T = 185.0,
        /// Exponential amplitude decay factor of the shell tone (default: 25.0).
        tone_decay_rate: T = 25.0,
        /// Mix level of the shell tone (default: 0.4).
        tone_level: T = 0.4,
        /// One-pole high-pass cutoff in Hz applied to the noise; must be > 0 (default: 1500.0).
        noise_cutoff_hz: T = 1500.0,
        /// Exponential amplitude decay factor of the noise (default: 18.0).
        noise_decay_rate: T = 18.0,
        /// Mix level of the high-passed noise (default: 0.5).
        noise_level: T = 0.5,
    };
}

/// Generates a Wave struct containing a synthesized snare hit.
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

/// Generates raw sample buffer containing a synthesized snare hit.
pub fn array(
    comptime T: type,
    allocator: std.mem.Allocator,
    sample_rate: u32,
    channels: u16,
    length: usize,
    volume: T,
    options: Options(T),
) ![]T {
    const rand = prng.random();
    var samples = try allocator.alloc(T, length * channels);

    const dt: T = 1.0 / @as(T, @floatFromInt(sample_rate));
    const rc: T = 1.0 / (2.0 * std.math.pi * options.noise_cutoff_hz);
    const alpha: T = rc / (rc + dt);
    var prev_noise: T = 0.0;
    var filtered: T = 0.0;

    for (0..samples.len / channels) |i| {
        const t: T = @as(T, @floatFromInt(i)) * dt;

        const phase: T = options.tone_frequency * t;
        const triangle: T = 1.0 - 4.0 * @abs(phase - @floor(phase + 0.5));
        const tone: T = triangle * std.math.exp(-options.tone_decay_rate * t);

        const noise: T = rand.float(T) * 2.0 - 1.0;
        filtered = alpha * (filtered + noise - prev_noise);
        prev_noise = noise;
        const wires: T = filtered * std.math.exp(-options.noise_decay_rate * t);

        const value: T = (tone * options.tone_level + wires * options.noise_level) * volume;

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
    reset();
    const actual = try array(f64, allocator, 44100, 1, length, volume, .{});
    defer allocator.free(actual);

    for (actual) |sample| {
        try std.testing.expect(@abs(sample) <= volume);
    }
    try std.testing.expect(@abs(actual[length - 1]) < 0.01);
}

test "reset produces bitwise deterministic output" {
    const allocator = std.testing.allocator;
    reset();
    const run1 = try array(f64, allocator, 44100, 1, 200, 0.5, .{});
    defer allocator.free(run1);

    reset();
    const run2 = try array(f64, allocator, 44100, 1, 200, 0.5, .{});
    defer allocator.free(run2);

    try std.testing.expectEqualSlices(f64, run1, run2);
}
