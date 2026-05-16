# Frame-Pair Skip

## Overview

This feature adds a `Frame pair skip` edit box to the Analyze panel. It lets `Analyze all frames` process every Nth frame pair instead of every pair.

Examples:

| Value | Behavior |
| --- | --- |
| `1` | Process all frame pairs, matching the original behavior |
| `2` | Process pair 1, 3, 5, ... |
| `3` | Process pair 1, 4, 7, ... |

## Files

| File | Role |
| --- | --- |
| `modified_code/+gui/generateUI.m` | Adds `frame_skip_text` and `frame_skip` controls |
| `modified_code/+piv/DCC_and_DFT_analyze_all.m` | Applies skip in parallel setup and serial analysis loops |

## GUI Change

The Analyze panel now contains:

- `handles.frame_skip_text`: label, `Frame pair skip:`
- `handles.frame_skip`: edit box, default `1`

The tooltip documents the expected values: `1` processes all pairs, `2` every second pair, `3` every third pair, and so on.

## Analysis Change

`DCC_and_DFT_analyze_all.m` reads the edit box, falls back to `1` for invalid or too-small values, rounds to an integer, and uses the value as the stride for frame-pair loops.

Parallel preprocessing now builds sliced image-pair lists with:

```matlab
for i=1:2*frame_skip:num_frames_to_process
```

Serial analysis now uses a compact result counter:

```matlab
result_idx=0;
for i=1:2*frame_skip_serial:num_frames_to_process
    result_idx=result_idx+1;
```

Result arrays, correlation matrices, file selector values, progress display, and remaining-time estimates use `result_idx` instead of `(i+1)/2`, so skipped frame pairs do not leave empty result slots.

## Notes

- The original frame-pair index is still used to select images and masks.
- The result list is compacted to only analyzed frame pairs.
- Ensemble PIV was not modified because it accumulates all pairs into one result, so this skip model does not map cleanly onto the current ensemble workflow.
