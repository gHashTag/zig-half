// zig-half — f16/bf16 SIMD library for Zig
//
// The re-exports below were written as `pub use module.{ A, B as C };`, which is
// Rust. Zig has no `use` statement and no `as` aliasing, so this file -- the
// module root, the surface every consumer imports -- has never been valid Zig,
// and the package has therefore never been usable by anybody. Nothing reported
// it because the repository had no workflow that built anything.
//
// Each of those blocks is now the Zig it was standing in for: one `pub const`
// per name, with the aliases preserved exactly as they were spelled.
//
// Extracted from Trinity HSLM training infrastructure.
// See: https://github.com/gHashTag/trinity

const std = @import("std");

// Re-export SIMD configuration and detection
pub const simd_config = @import("simd_config.zig");
pub const capabilities = simd_config.capabilities;
pub const VecF16 = simd_config.VecF16;
pub const VecF32 = simd_config.VecF32;
pub const VecI8 = simd_config.VecI8;
pub const zeroVecF16 = simd_config.zeroVecF16;
pub const zeroVecF32 = simd_config.zeroVecF32;
pub const zeroVecI8 = simd_config.zeroVecI8;

// Re-export f16 utilities
pub const f16_utils = @import("f16_utils.zig");
pub const VEC_F16_SIZE = f16_utils.VEC_F16_SIZE;
pub const VecF16Alias = f16_utils.VecF16;
pub const VecF32Alias = f16_utils.VecF32;
pub const zeroVecF16Alias = f16_utils.zeroVecF16;
pub const zeroVecF32Alias = f16_utils.zeroVecF32;
pub const f32ToF16Slice = f16_utils.f32ToF16Slice;
pub const f16ToF32Slice = f16_utils.f16ToF32Slice;
pub const vecF16ToF32 = f16_utils.vecF16ToF32;
pub const vecF32ToF16 = f16_utils.vecF32ToF16;
pub const isTernarySafeF16 = f16_utils.isTernarySafeF16;
pub const countTernarySafeF16 = f16_utils.countTernarySafeF16;
pub const countNonFiniteF16 = f16_utils.countNonFiniteF16;
pub const maxAbsF16 = f16_utils.maxAbsF16;
pub const maxAbsF16Simd = f16_utils.maxAbsF16Simd;
pub const dotProductF16 = f16_utils.dotProductF16;
pub const l2NormF16 = f16_utils.l2NormF16;
pub const cosineSimilarityF16 = f16_utils.cosineSimilarityF16;
pub const quantizeF16ToTernary = f16_utils.quantizeF16ToTernary;

// Re-export f16 shadow weights
pub const f16_shadow = @import("f16_shadow.zig");
pub const F16ShadowStorage = f16_shadow.F16ShadowStorage;
pub const f32ToF16SliceShadow = f16_shadow.f32ToF16Slice;
pub const f16ToF32SliceShadow = f16_shadow.f16ToF32Slice;
pub const dotProductF16Shadow = f16_shadow.dotProductF16;

// Re-export sparse SIMD
pub const sparse_simd = @import("sparse_simd.zig");
pub const VEC_I8_SIZE = sparse_simd.VEC_I8_SIZE;
pub const VEC_F16_SIZE_Sparse = sparse_simd.VEC_F16_SIZE;
pub const VEC_F32_SIZE_Sparse = sparse_simd.VEC_F32_SIZE;
pub const VecI8Alias = sparse_simd.VecI8;
pub const VecF16SparseAlias = sparse_simd.VecF16;
pub const VecF32SparseAlias = sparse_simd.VecF32;
pub const zeroVecI8Alias = sparse_simd.zeroVecI8;
pub const zeroVecF16SparseAlias = sparse_simd.zeroVecF16;
pub const sparseTernaryDot = sparse_simd.sparseTernaryDot;
pub const denseTernaryDot = sparse_simd.denseTernaryDot;
pub const sparseTernaryMatvec = sparse_simd.sparseTernaryMatvec;
pub const denseTernaryMatvec = sparse_simd.denseTernaryMatvec;
pub const countZeroChunks = sparse_simd.countZeroChunks;
pub const sparsityRatio = sparse_simd.sparsityRatio;
pub const estimateSpeedup = sparse_simd.estimateSpeedup;

// Re-export ternary packing
pub const ternary_pack = @import("ternary_pack.zig");
pub const packTernary16 = ternary_pack.packTernary16;
pub const unpackTernary16 = ternary_pack.unpackTernary16;
pub const packTernarySlice = ternary_pack.packTernarySlice;
pub const unpackTernarySlice = ternary_pack.unpackTernarySlice;
pub const tritToChar = ternary_pack.tritToChar;
pub const charToTrit = ternary_pack.charToTrit;
pub const tritsToString = ternary_pack.tritsToString;
pub const stringToTrits = ternary_pack.stringToTrits;
pub const countTrits = ternary_pack.countTrits;
pub const compressionRatio = ternary_pack.compressionRatio;

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
