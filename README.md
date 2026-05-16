# PIVlab Modifications Summary

This repository records the local PIVlab changes made in May 2026 and stores the modified MATLAB source files under `modified_code/`.

The local PIVlab checkout is not a git repository, so the change list was reconstructed by combining the existing summary notes, recent file timestamps, keyword inspection, and comparison against the public PIVlab repository. The confirmed feature changes are the motion-based automask workflow and frame-pair skipping during batch analysis. A few nearby GUI/local-compatibility files are also included because they were recently changed in the local PIVlab folder.

## Modified Code

| Local PIVlab path | Copy in this repository | Purpose |
| --- | --- | --- |
| `+mask/compute_motion_mask.m` | `modified_code/+mask/compute_motion_mask.m` | New core motion-mask calculation |
| `+mask/motion_automask_Callback.m` | `modified_code/+mask/motion_automask_Callback.m` | New generate-all callback for motion masks |
| `+mask/bright_or_dark_Callback.m` | `modified_code/+mask/bright_or_dark_Callback.m` | Shows the new motion-mask settings panel |
| `+mask/automask_preview_Callback.m` | `modified_code/+mask/automask_preview_Callback.m` | Routes preview generation through motion masking |
| `+mask/automask_generate_current_Callback.m` | `modified_code/+mask/automask_generate_current_Callback.m` | Routes current-frame generation through motion masking |
| `+mask/automask_generate_all_Callback.m` | `modified_code/+mask/automask_generate_all_Callback.m` | Routes generate-all to `motion_automask_Callback` |
| `+gui/generateUI.m` | `modified_code/+gui/generateUI.m` | Adds motion-mask controls and frame-pair-skip UI |
| `+piv/DCC_and_DFT_analyze_all.m` | `modified_code/+piv/DCC_and_DFT_analyze_all.m` | Adds frame-pair skip to serial and parallel analysis |
| `+gui/uipickfiles.m` | `modified_code/+gui/uipickfiles.m` | Local GUI/file-picker compatibility changes |
| `+gui/uipickfiles_pre_2025.m` | `modified_code/+gui/uipickfiles_pre_2025.m` | Same file-picker compatibility changes for the legacy picker |
| `+gui/MainWindow_ResizeFcn.m` | `modified_code/+gui/MainWindow_ResizeFcn.m` | Local resize behavior version |
| `+gui/switchui.m` | `modified_code/+gui/switchui.m` | Minor local switch-panel edit |

## Feature Documentation

| Feature | Documentation |
| --- | --- |
| Motion-based automask, including optional per-frame object/bubble masking | `01_motion_based_automask.md` |
| Frame-pair skip during Analyze All | `02_frame_skip_analysis.md` |
| Code review notes and residual risks | `CODE_REVIEW.md` |

## Confirmed Functional Changes

1. Added a `Motion-based mask generator` option to the mask generator dropdown.
2. Added a dedicated motion settings panel with controls for percentile threshold, frame interval, sampled frame pairs, morphology smoothing, minimum flow-region size, and optional object/bubble masking.
3. Added motion-mask preview, current-frame generation, and all-frame generation paths.
4. Added `Frame pair skip` in the Analyze panel to process every Nth image pair.
5. Updated batch result indexing and progress reporting so skipped frame pairs produce compact result lists.

## Dependencies

These changes rely on Image Processing Toolbox functions including `rgb2gray`, `im2double`, `prctile`, `strel`, `imclose`, `imfill`, `bwareaopen`, `bwboundaries`, `bwconncomp`, `stdfilt`, `imerode`, `imdilate`, and optionally `adapthisteq`.
