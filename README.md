# PIVlab Modifications Overview

## Modification Date
May 2026

## Modifications

| Feature | Category | Detailed Documentation |
|---------|----------|------------------------|
| Motion-Based Automask | New Feature (Masking) | [01_motion_based_automask.md](01_motion_based_automask.md) |
| Frame Pair Skip | New Feature (Analysis) | [02_frame_skip_analysis.md](02_frame_skip_analysis.md) |

## List of Involved Files

### New Files
| File Path | Functionality |
|-----------|---------------|
| `+mask/compute_motion_mask.m` | Core computation for motion mask |
| `+mask/motion_automask_Callback.m` | Callback for applying motion mask to all frames |

### Modified Files
| File Path | Modification Details |
|-----------|----------------------|
| `+gui/generateUI.m` | Added motion mask panel (`uipanel25_11`), dropdown option, and `frame_skip` UI control |
| `+mask/bright_or_dark_Callback.m` | Added panel switching logic for the motion option (`Value==4`) |
| `+mask/automask_preview_Callback.m` | Added preview routing for motion mode |
| `+mask/automask_generate_current_Callback.m` | Added single-frame generation routing for motion mode |
| `+mask/automask_generate_all_Callback.m` | Added all-frames generation routing for motion mode |
| `+piv/DCC_and_DFT_analyze_all.m` | Added frame skip support (in both parallel and serial loops) |

## Dependencies
- Image Processing Toolbox (`bwboundaries`, `imclose`, `imfill`, `bwareaopen`, `strel`, `imadjust`, `rgb2gray`)
