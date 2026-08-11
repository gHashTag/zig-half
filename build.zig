// zig-half build script
//
// The previous version of this file had never compiled and could not have. It
// declared `pub fn test(b: *std.Build)`, and `test` is a keyword; it assigned
// `b.standardTargetOptions` without calling it; it passed two arguments to
// installArtifact and read `b.step` as a field. None of that is a version
// difference -- it is a sketch shaped like a build script, and nothing in this
// repository ever ran it, because there was no workflow that built anything.
//
// Rewritten for 0.15, the version the packages that would consume this are
// built with.
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root = b.addModule("zig-half", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    _ = root;

    const lib = b.addLibrary(.{
        .name = "zig-half",
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    b.installArtifact(lib);

    // One test target per file, as before, plus the module root. The root was
    // not tested at all previously, which is the surface every consumer gets:
    // Zig analyses top-level declarations lazily, so a test run over the other
    // files proves nothing about the declarations they do not reference.
    const test_step = b.step("test", "Run the tests");
    for ([_][]const u8{
        "src/root.zig",
        "src/f16_utils.zig",
        "src/f16_shadow.zig",
        "src/sparse_simd.zig",
        "src/ternary_pack.zig",
        "src/simd_config.zig",
    }) |path| {
        const t = b.addTest(.{
            .root_module = b.createModule(.{
                .root_source_file = b.path(path),
                .target = target,
                .optimize = optimize,
            }),
        });
        test_step.dependOn(&b.addRunArtifact(t).step);
    }
}
