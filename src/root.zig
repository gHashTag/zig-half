// zig-half — f16/bf16 SIMD library for Zig
//
// A high-performance half-precision float library with:
// - Adaptive SIMD width (AVX2, AVX-512, NEON, SSE2)
// - f16 ↔ f32 conversions with zero-copy vectorization
// - Ternary quantization {-1, 0, +1} with 2-bit packing
// - Sparse ternary matvec with zero-chunk skipping
// - Shadow weight storage for gradient accumulation
// - Comprehensive benchmarks
//
// Extracted from Trinity HSLM training infrastructure.
// See: https://github.com/gHashTag/trinity

const std = @import("std");

// Re-export SIMD configuration and detection
pub const simd_config = @import("simd_config.zig");
pub use simd_config.{ capabilities, VecF16, VecF32, VecI8, zeroVecF16, zeroVecF32, zeroVecI8 };

// Re-export f16 utilities
pub const f16_utils = @import("f16_utils.zig");
pub use f16_utils.{
    VEC_F16_SIZE,
    VEC_F32_SIZE,
    VecF16 as VecF16Alias,
    VecF32 as VecF32Alias,
    zeroVecF16 as zeroVecF16Alias,
    zeroVecF32 as zeroVecF32Alias,
    f32ToF16Slice,
    f16ToF32Slice,
    vecF16ToF32,
    vecF32ToF16,
    isTernarySafeF16,
    countTernarySafeF16,
    countNonFiniteF16,
    maxAbsF16,
    maxAbsF16Simd,
    dotProductF16,
    l2NormF16,
    cosineSimilarityF16,
    quantizeF16ToTernary,
};

// Re-export f16 shadow weights
pub const f16_shadow = @import("f16_shadow.zig");
pub use f16_shadow.{
    F16ShadowStorage,
    DEFAULT_SYNC_INTERVAL,
    DEFAULT_QUANTIZE_THRESHOLD,
    f32ToF16Slice as f32ToF16SliceShadow,
    f16ToF32Slice as f16ToF32SliceShadow,
    dotProductF16 as dotProductF16Shadow,
};

// Re-export sparse SIMD
pub const sparse_simd = @import("sparse_simd.zig");
pub use sparse_simd.{
    VEC_I8_SIZE,
    VEC_F16_SIZE as VEC_F16_SIZE_Sparse,
    VEC_F32_SIZE as VEC_F32_SIZE_Sparse,
    VecI8 as VecI8Alias,
    VecF16 as VecF16SparseAlias,
    VecF32 as VecF32SparseAlias,
    zeroVecI8 as zeroVecI8Alias,
    zeroVecF16 as zeroVecF16SparseAlias,
    sparseTernaryDot,
    denseTernaryDot,
    sparseTernaryMatvec,
    denseTernaryMatvec,
    countZeroChunks,
    sparsityRatio,
    estimateSpeedup,
};

// Re-export ternary packing
pub const ternary_pack = @import("ternary_pack.zig");
pub use ternary_pack.{
    TRIT_NEG,
    TRIT_ZERO,
    TRIT_POS,
    packTernary16,
    unpackTernary16,
    packTernarySlice,
    unpackTernarySlice,
    tritToChar,
    charToTrit,
    tritsToString,
    stringToTrits,
    countTrits,
    compressionRatio,
};

// ═════════════════════════════════════════════════════════════════════════════
// VERSION & INFO
// ═════════════════════════════════════════════════════════════════════════════════════

pub const VERSION = "0.1.0";
pub const BUILD_DATE = "2026-03-19";

/// Get library version as string
pub inline fn versionString() []const u8 {
    return VERSION;
}

/// Print SIMD configuration at runtime
pub inline fn printConfig() void {
    simd_config.printSimdConfig();
}

// ═════════════════════════════════════════════════════════════════════════════
// EXAMPLE USAGE
// ═══════════════════════════════════════════════════════════════════════════════════════

// const std = @import("std");
// const zig_half = @import("zig-half");
//
// pub fn main() !void {
//     // Convert f32 to f16
//     const f32_data = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
//     var f16_data: [4]f16 = undefined;
//     zig_half.f32ToF16Slice(&f32_data, &f16_data);
//
//     // Dot product with adaptive SIMD
//     const dot = zig_half.dotProductF16(&f16_data, &f16_data);
//     std.debug.print("dot = {d:.2}\n", .{dot});
//
//     // Ternary quantization
//     var ternary: [4]i8 = undefined;
//     zig_half.quantizeF16ToTernary(&f16_data, 0.5, &ternary);
//
//     // 2-bit packing
//     const packed = zig_half.packTernary16([_]i8{ -1, 0, 1, -1 });
//     const unpacked = zig_half.unpackTernary16(packed);
//     std.debug.print("packed = 0x{x}, unpacked = {any}\n", .{ packed, unpacked });
//
//     // Sparse ternary dot product
//     const weights = [_]i8{ 1, 0, -1, 0, 1 };
//     const activations = [_]f16{ 0.5, 0.3, -0.7, 0.2, 0.5 };
//     const sparse_dot = zig_half.sparseTernaryDot(&weights, &activations);
//     std.debug.print("sparse dot = {d:.2}\n", .{sparse_dot });
//
//     // Print SIMD info
//     zig_half.printConfig();
// }

test "every public declaration of this module is analysed" {
    // src/root.zig is what a consumer imports, and no test target rooted it
    // before -- so the one surface that matters was the one never compiled.
    // The same omission hid sixteen defects in gHashTag/zig-golden-float and
    // five in gHashTag/zig-hdc.
    @import("std").testing.refAllDeclsRecursive(@This());
}
