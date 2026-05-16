# Code Review Notes

## Scope Checked

I reviewed the local modified MATLAB files copied into `modified_code/`, with focus on the motion automask workflow and frame-pair skip workflow.

## Findings

1. `compute_motion_mask.m` does not validate all numeric GUI inputs before using them.
   Invalid `motion_percentile`, `motion_frame_interval`, `motion_num_pairs`, `motion_min_size`, or `motion_smooth_size` values can flow into `linspace`, `prctile`, `strel`, or loop bounds. The frame-skip code already has a fallback pattern; the motion-mask code should use the same style before production use.

2. `motion_automask_Callback.m` assumes every odd frame has a following even frame.
   The loop uses `for i = 1:2:num_frames_process` and then calls `import.get_img(i+1)`. If an odd number of frames is loaded, the last iteration can request a non-existent frame. The older non-motion generate-all path has the same shape, but the new callback should clamp to the last complete pair for robustness.

3. Object/bubble detection is duplicated in preview, generate-current, and generate-all.
   The duplicated block is behaviorally consistent, but it increases maintenance risk. A helper such as `mask.compute_motion_object_mask(base_mask, imageA, imageB, handles)` would make future tuning safer.

4. `compute_motion_mask.m` can produce a blank or all-static mask if no valid pairs are accumulated.
   It initializes `motion_map` to zeros and still thresholds it even when `valid_pairs` is zero. A clearer fallback or user-facing warning would make debugging bad frame selections easier.

5. The `Frame pair skip` result compaction is intentional but changes result indexing semantics.
   With skip greater than one, result slot 2 represents the second processed pair, not the original second frame pair. This is efficient, but downstream scripts that assume result index equals original pair index need to account for the skip value.

## Checks Performed

- Confirmed modified files exist in the local PIVlab folder.
- Searched for all motion and frame-skip symbols across the modified files.
- Compared recent local files against public PIVlab source, while noting that the local folder is not a git checkout and does not exactly match public `HEAD`.
- Verified the repository now contains the modified MATLAB source files under `modified_code/`.
