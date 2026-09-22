//! Hi-hat percussion generator: white noise burst with a fast exponential decay.

const std = @import("std");
const lightmix = @import("lightmix");

var prng = std.Random.DefaultPrng.init(0);

/// Resets the internal pseudo-random number generator to its initial deterministic seed.
pub fn reset() void {
    prng = std.Random.DefaultPrng.init(0);
}

/// Synthesis configuration options for the hi-hat generator.
pub fn Options(comptime T: type) type {
    return struct {
        /// Exponential amplitude decay factor (default: 40.0).
        decay_rate: T = 40.0,
    };
}

/// Generates a Wave struct containing a synthesized hi-hat hit.
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

/// Generates raw sample buffer containing a synthesized hi-hat hit.
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

    for (0..samples.len / channels) |i| {
        const t: T = @as(T, @floatFromInt(i)) / @as(T, @floatFromInt(sample_rate));
        const env: T = std.math.exp(-options.decay_rate * t);
        const noise: T = (rand.float(T) * 2.0 - 1.0) * 0.5;
        const value: T = noise * env * volume;

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
