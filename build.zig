const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lightmix = b.dependency("lightmix", .{});
    const lightmix_import: std.Build.Module.Import = .{ .name = "lightmix", .module = lightmix.module("lightmix") };

    // Genre modules
    const analog_synth = b.createModule(.{
        .root_source_file = b.path("modules/analog-synth/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{lightmix_import},
    });
    const drums = b.createModule(.{
        .root_source_file = b.path("modules/drums/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{lightmix_import},
    });
    const fm_synth = b.createModule(.{
        .root_source_file = b.path("modules/fm-synth/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{lightmix_import},
    });
    const ambient = b.createModule(.{
        .root_source_file = b.path("modules/ambient/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{lightmix_import},
    });

    const imports: []const std.Build.Module.Import = &.{
        lightmix_import,
        .{ .name = "analog_synth", .module = analog_synth },
        .{ .name = "drums", .module = drums },
        .{ .name = "fm_synth", .module = fm_synth },
        .{ .name = "ambient", .module = ambient },
    };

    // Public library module (this is what `b.dependency("timbrefolio", .{}).module("timbrefolio")` resolves to)
    const mod = b.addModule("timbrefolio", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = imports,
    });

    const lib = b.addLibrary(.{
        .name = "timbrefolio",
        .root_module = mod,
        .linkage = .static,
    });
    b.installArtifact(lib);

    // Tests
    const analog_synth_tests = b.addTest(.{ .root_module = analog_synth });
    const run_analog_synth_tests = b.addRunArtifact(analog_synth_tests);

    const drums_tests = b.addTest(.{ .root_module = drums });
    const run_drums_tests = b.addRunArtifact(drums_tests);

    const fm_synth_tests = b.addTest(.{ .root_module = fm_synth });
    const run_fm_synth_tests = b.addRunArtifact(fm_synth_tests);

    const ambient_tests = b.addTest(.{ .root_module = ambient });
    const run_ambient_tests = b.addRunArtifact(ambient_tests);

    const mod_tests = b.addTest(.{ .root_module = mod });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_analog_synth_tests.step);
    test_step.dependOn(&run_drums_tests.step);
    test_step.dependOn(&run_fm_synth_tests.step);
    test_step.dependOn(&run_ambient_tests.step);
    test_step.dependOn(&run_mod_tests.step);

    // Sandbox previews
    const sandbox_step = b.step("sandbox", "Generate preview wav files for each starter instrument");
    try build_sandbox(b, target, optimize, imports, sandbox_step);
}

fn build_sandbox(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    imports: []const std.Build.Module.Import,
    sandbox_step: *std.Build.Step,
) !void {
    const paths_names: []const struct { []const u8, []const u8 } = &.{
        .{ "sandbox/pluck/mono-220.0.zig", "pluck-mono-220.0.wav" },
        .{ "sandbox/hihat/mono.zig", "hihat-mono.wav" },
        .{ "sandbox/bell/mono-440.0.zig", "bell-mono-440.0.wav" },
        .{ "sandbox/drone/mono-110.0.zig", "drone-mono-110.0.wav" },
    };

    inline for (paths_names) |pn| {
        const path = pn.@"0";
        const name = pn.@"1";

        const mod = b.createModule(.{
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
            .imports = imports,
        });

        const wave = try l.addWave(b, mod, .{
            .optimize = optimize,
            .format = .{ .wav = .{
                .bits = 16,
                .format_code = .pcm,
                .name = name,
            } },
            .path = .{ .custom = "share/sandbox" },
        });
        sandbox_step.dependOn(wave.step);
    }
}
