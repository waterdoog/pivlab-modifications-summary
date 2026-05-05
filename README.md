# PIVlab 修改总览

## 修改时间
2026年5月

## 修改内容

| 功能 | 类别 | 详细文档 |
|------|------|----------|
| Motion-Based Automask | 新功能 (遮罩) | [01_motion_based_automask.md](01_motion_based_automask.md) |
| Frame Pair Skip | 新功能 (分析) | [02_frame_skip_analysis.md](02_frame_skip_analysis.md) |

## 涉及的文件清单

### 新增文件
| 文件路径 | 功能 |
|----------|------|
| `+mask/compute_motion_mask.m` | Motion mask核心计算 |
| `+mask/motion_automask_Callback.m` | Motion mask全帧应用回调 |

### 修改文件
| 文件路径 | 修改内容 |
|----------|----------|
| `+gui/generateUI.m` | 新增motion mask面板(uipanel25_11)、dropdown选项、frame_skip控件 |
| `+mask/bright_or_dark_Callback.m` | 新增motion选项(Value==4)的面板切换 |
| `+mask/automask_preview_Callback.m` | 新增motion模式预览路由 |
| `+mask/automask_generate_current_Callback.m` | 新增motion模式单帧生成路由 |
| `+mask/automask_generate_all_Callback.m` | 新增motion模式全帧生成路由 |
| `+piv/DCC_and_DFT_analyze_all.m` | 添加frame skip支持（并行+串行循环） |

## 依赖
- Image Processing Toolbox (`bwboundaries`, `imclose`, `imfill`, `bwareaopen`, `strel`, `imadjust`, `rgb2gray`)
