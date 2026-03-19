// zig-half build script
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions;
    const optimize = b.standardOptimizeOption;

    const lib = b.addStaticLibrary(.{
        .name = "zig-half",
        .root_source_file = "src/root.zig",
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(lib, .{});
}

pub fn test(b: *std.Build) !void {
    const test_step = b.addTest(.{
        .root_source_file = "src/f16_utils.zig",
        .name = "f16_utils_tests",
    });

    _ = b.addTest(.{
        .root_source_file = "src/f16_shadow.zig",
        .name = "f16_shadow_tests",
    });

    _ = b.addTest(.{
        .root_source_file = "src/sparse_simd.zig",
        .name = "sparse_simd_tests",
    });

    _ = b.addTest(.{
        .root_source_file = "src/ternary_pack.zig",
        .name = "ternary_pack_tests",
    });

    _ = b.addTest(.{
        .root_source_file = "src/simd_config.zig",
        .name = "simd_config_tests",
    });

    b.step.dependOn(&test_step.step);
}
