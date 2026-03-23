# Balanced Ternary (Base-3) Formatting for Zig std/fmt

## Summary

This PR adds support for balanced ternary (base-3) number formatting to `std.fmt.formatInt`.

## What is Balanced Ternary?

Balanced ternary uses digits `T` (-1), `0`, `1` instead of `0, 1, 2` like standard ternary. This is the native numeric system of Trinity architecture.

| Decimal | Balanced Ternary | Standard Ternary |
|---------|-----------------|-----------------|
| 0 | `0` | `0` |
| 1 | `1` | `1` |
| 2 | `1T` | `2` |
| 3 | `10` | `10` |
| 4 | `11` | `11` |
| 5 | `1TT` | `12` |
| -1 | `T` | `2` |
| -5 | `T11` | `12` |
| 16 | `1TT1` | `121` |
| 364 | `111111` | `111111` |

## Implementation Plan

The change should be minimal and focused:

1. Add `formatIntBase3()` function in `lib/std/fmt.zig`
2. Add branch check: `if (comptime base == 3)`
3. Implement balanced ternary conversion
4. Add tests in `lib/std/fmt/test.zig`

## Test Cases

```
0   → 0
1   → 1
2   → 1T
3   → 10
16  → 1TT1
364 → 111111
-1  → T
-5  → T11
```

## Open Questions

- Should this be a comptime-only function or runtime-able?
- Should we support negative numbers with sign prefix?
- Should this be opt-in or always available for base-3?

## Notes

This is a proposal for discussion. The actual implementation should follow Zig stdlib conventions and be reviewed by maintainers before merging.

---

φ² + 1/φ² = 3 | TRINITY
