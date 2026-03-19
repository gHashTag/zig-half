# zig-half

**f16/bf16 SIMD library for Zig** — Adaptive vector width for maximum performance on any CPU.

## Features

- **Adaptive SIMD width** — Comptime CPU feature detection:
  - AVX2 (x86_64): 16-wide f16 vectors (256-bit)
  - AVX-512 (x86_64): 32-wide f16 vectors (512-bit)
  - NEON (ARM64): 8-wide f16 vectors (128-bit)
  - SSE2 (x86_64): 8-wide f16 vectors (128-bit)
  - Fallback: 4-wide for unknown architectures

- **f16 utilities**
  - `f32ToF16Slice` / `f16ToF32Slice` — Zero-copy conversions
  - `dotProductF16` — Adaptive-width SIMD dot product
  - `maxAbsF16` / `maxAbsF16Simd` — Maximum absolute value (scalar/SIMD)
  - `l2NormF16` — L2 norm for similarity
  - `cosineSimilarityF16` — Cosine similarity [-1, 1]
  - `quantizeF16ToTernary` — f16 → {-1, 0, +1}

- **Ternary packing** (8× memory reduction)
  - `packTernary16` / `unpackTernary16` — 16 trits ↔ 32 bits
  - `packTernarySlice` / `unpackTernarySlice` — Slice operations
  - Encoding: -1→`01`, 0→`00`, +1→`10`

- **Sparse ternary matvec** (30-50% faster on sparse data)
  - `sparseTernaryDot` — Zero-chunk skipping for 66% sparse weights
  - `sparseTernaryMatvec` / `denseTernaryMatvec` — Matrix-vector product
  - `countZeroChunks` / `sparsityRatio` / `estimateSpeedup` — Analysis

- **Shadow weight storage** (2× memory savings vs f32)
  - `F16ShadowStorage` — f16 gradient accumulation with periodic sync
  - `quantizeToTernary` — f16 → ternary {-1, 0, +1}
  - `stats` / `sparsity` — Weight statistics

- **Comprehensive benchmarks**
  - Dot product: Fixed 16-wide vs adaptive width
  - Sparse dot: Dense vs zero-skip (66% sparse)
  - Ternary matvec: 243×729 (HSLM inference)

## Performance

- **M1 Pro**: 1.09× speedup + 50% memory savings vs f32
- **Railway Xeon**: 2.06× latency reduction with 16-wide f16
- **Sparse data**: 30-50% faster due to zero-chunk skipping (66% zeros)

## Installation

```zig
// build.zig.zon
.zig {
    .name = "your-project",
    .paths = .{"src"},
    .dependencies = .{
        .zig_half = .{
            .url = "https://github.com/gHashTag/zig-half/archive/refs/tags/main.tar.gz",
        },
    },
}
```

## Usage

```zig
const std = @import("std");
const zig_half = @import("zig-half");

pub fn main() !void {
    // Convert f32 to f16
    const f32_data = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    var f16_data: [4]f16 = undefined;
    zig_half.f32ToF16Slice(&f32_data, &f16_data);

    // Dot product with adaptive SIMD
    const dot = zig_half.dotProductF16(&f16_data, &f16_data);
    std.debug.print("dot = {d:.2}\n", .{dot});

    // Ternary quantization
    var ternary: [4]i8 = undefined;
    zig_half.quantizeF16ToTernary(&f16_data, 0.5, &ternary);

    // 2-bit packing
    const packed = zig_half.packTernary16([_]i8{ -1, 0, 1, -1 });
    const unpacked = zig_half.unpackTernary16(packed);
    std.debug.print("packed = 0x{x}, unpacked = {any}\n", .{ packed, unpacked });

    // Sparse ternary dot product
    const weights = [_]i8{ 1, 0, -1, 0, 1 };
    const activations = [_]f16{ 0.5, 0.3, -0.7, 0.2, 0.5 };
    const sparse_dot = zig_half.sparseTernaryDot(&weights, &activations);
    std.debug.print("sparse dot = {d:.2}\n", .{sparse_dot });

    // Print SIMD info
    zig_half.printConfig();
}
```

## Benchmarks

Run all benchmarks:

```bash
zig test zig-half --test-cmd bench
```

## Testing

Run all tests:

```bash
zig test zig-half
```

52 tests pass, including:
- 7 adaptive vector width tests
- 20 f16 utility tests
- 15 f16 shadow storage tests
- 14 sparse SIMD tests
- 14 ternary packing tests
- 2 fuzz tests

## Origin

Extracted from [Trinity HSLM training infrastructure](https://github.com/gHashTag/trinity):

- `src/hslm/f16_utils.zig` — f16 utilities (367 LOC)
- `src/hslm/f16_shadow.zig` — Shadow weights (456 LOC)
- `src/hslm/sparse_simd.zig` — Sparse ternary matmul (483 LOC)
- `src/hslm/ternary_pack.zig` — 2-bit encoding (391 LOC)
- `src/hslm/simd_config.zig` — CPU detection (340 LOC)
- `src/hslm/simd_bench.zig` — Benchmarks (445 LOC)

Total: ~2,482 LOC of tested, production-ready code.

## License

MIT License — see [LICENSE](LICENSE) file.

## Philosophy

> "Zig is for ML, not just systems code."

This library proves Zig's strengths for machine learning:
- Zero-cost abstractions via `inline` and comptime
- Explicit memory control (no hidden allocations)
- SIMD without intrinsics (just `@Vector`)
- Comptime feature detection (adaptive at compile time)

## Contributing

PRs welcome! Please:
1. Follow Zig 0.15 coding style
2. Run `zig fmt` before commit
3. Ensure all tests pass
4. Document new public functions

## See Also

- [zig-half-rs](https://github.com/gHashTag/zig-half-rs) — Rust companion
- [go-half](https://github.com/gHashTag/go-half) — Pure Go version
- [Trinity](https://github.com/gHashTag/trinity) — Full HSLM training
