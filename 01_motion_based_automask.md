# Motion-Based Automask

## Overview

This feature adds a new mask generator for image sequences where moving tracer particles identify the flow/channel region and static areas should be masked out. It is useful for microfluidic PIV data where walls, reflections, or stationary regions should be excluded.

The current local code also includes optional per-frame object detection for smooth large objects such as bubbles. That object mask is combined with the static-wall mask for preview, current-frame generation, and generate-all.

## Files

| File | Role |
| --- | --- |
| `modified_code/+mask/compute_motion_mask.m` | Computes the base static-region mask from inter-frame motion |
| `modified_code/+mask/motion_automask_Callback.m` | Applies the base mask, plus optional object masks, across all frame pairs |
| `modified_code/+mask/automask_preview_Callback.m` | Adds motion-mode preview support |
| `modified_code/+mask/automask_generate_current_Callback.m` | Adds motion-mode current-frame support |
| `modified_code/+mask/automask_generate_all_Callback.m` | Dispatches motion generate-all to `motion_automask_Callback` |
| `modified_code/+mask/bright_or_dark_Callback.m` | Switches the GUI to the motion settings panel |
| `modified_code/+gui/generateUI.m` | Adds the dropdown option and motion settings controls |

## Base Motion Mask Algorithm

`compute_motion_mask` reads these GUI fields:

| GUI handle | Default | Meaning |
| --- | --- | --- |
| `motion_percentile` | `60` | Percentile threshold for the averaged motion map |
| `motion_frame_interval` | `1` | Frame offset used when comparing images |
| `motion_num_pairs` | `10` | Number of frame pairs sampled across the sequence |
| `motion_min_size` | `1000` | Small moving regions below this pixel area are removed |
| `motion_smooth_size` | `3` | Disk radius used for morphological closing |

Process:

1. Sample image pairs across the sequence.
2. Convert color images to grayscale.
3. Accumulate `abs(frame_i - frame_i+interval)` into a mean `motion_map`.
4. Threshold `motion_map` by percentile to get the moving flow region.
5. Smooth the moving region with closing, fill holes, and remove small components.
6. Invert the moving region so the final `pixel_mask` masks static/non-flow areas.

## Optional Object/Bubble Masking

The local code adds optional per-frame object detection controlled by these GUI fields:

| GUI handle | Default | Meaning |
| --- | --- | --- |
| `motion_bubble_size_chk` | off | Enables object detection |
| `motion_bubble_size` | `800` | Minimum detected object size in pixels |
| `motion_contrast_pct_chk` | on | Applies CLAHE before object detection |
| `motion_contrast_pct` | `20` | Local-standard-deviation percentile for smooth-object detection |
| `motion_max_objects_chk` | on | Limits detected object count |
| `motion_max_objects` | `1` | Keeps the N largest detected objects |
| `motion_bubble_dilate_chk` | on | Expands detected object masks |
| `motion_bubble_dilate` | `5` | Dilation radius in pixels |

Object detection is restricted to the computed flow region. It uses local standard deviation (`stdfilt`) to find smooth areas, cleans them morphologically, optionally keeps only the largest N components, dilates them, then merges them into the final mask with `pixel_mask | detected`.

## GUI Integration

`generateUI.m` adds the `Motion-based mask generator` dropdown entry and the `uipanel25_11` settings panel. `bright_or_dark_Callback.m` displays this panel when the dropdown value is `4` and hides it for all other modes.

The existing automask actions were extended as follows:

| Action | Motion-mode behavior |
| --- | --- |
| Preview | Computes base motion mask, optionally adds detected object mask for the selected frame pair, displays overlay |
| Generate current | Computes base motion mask, optionally adds detected object mask for the selected frame pair, converts mask to ROIs |
| Generate all | Calls `motion_automask_Callback`, then applies each generated frame mask as ROIs |

## Usage

1. Load an image sequence.
2. Open the Mask panel.
3. Switch mask capabilities to Expert.
4. Select `Motion-based mask generator`.
5. Tune the motion parameters, then use Preview, Generate current, or Generate all.
