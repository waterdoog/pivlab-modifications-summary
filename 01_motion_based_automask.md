# Motion-Based Automask Feature

## 概述
新增基于帧间运动检测的自动遮罩功能。通过计算连续帧之间的差异来区分流动区域（粒子在帧间移动）和静态区域（壁面/反射不动），自动生成遮罩。适用于微流控PIV等场景。

## 算法原理
1. 从图像序列中均匀采样多对帧
2. 计算每对帧的绝对差值 `abs(frame_i+N - frame_i)`
3. 对所有采样帧对的差值取平均，得到 motion_map
4. 以百分位数阈值对 motion_map 二值化，得到运动区域(motion_region)
5. 对**运动区域**做形态学后处理：闭操作(imclose) → 填充(imfill) → 去小区域(bwareaopen)
6. 取反 `~motion_region` 得到静止区域作为最终遮罩(pixel_mask)
7. 将二值遮罩转换为ROI多边形并应用到所有帧

**注意：** 形态学操作在运动区域（流道）上执行，确保流道边缘平滑。之后取反得到静止区域（壁面）作为mask。如果直接在静止区域上做形态学，边缘效果会不好。

## 新增文件

### `+mask/compute_motion_mask.m`
核心计算函数。从GUI控件读取参数，执行运动检测算法，返回 pixel_mask。

**参数（从GUI读取）：**
- `motion_percentile`: 百分位阈值 (0-100)，越高越严格，默认60
- `motion_frame_interval`: 帧间隔，默认1
- `motion_num_pairs`: 采样帧对数，默认10
- `motion_min_size`: 最小区域面积(像素)，默认1000

**关键逻辑：**
```matlab
pair_indices = round(linspace(1, num_frames - frame_interval, num_pairs));
for k = 1:numel(pair_indices)
    motion_map = motion_map + abs(im2double(img1) - im2double(img2));
end
motion_map = motion_map / valid_pairs;
threshold_val = prctile(motion_map(:), percentile);

% 先检测运动区域（流道）
motion_region = motion_map >= threshold_val;

% 对运动区域做形态学清理（确保流道边缘平滑）
motion_region = imclose(motion_region, strel('disk', 3));
motion_region = imfill(motion_region, 'holes');
motion_region = bwareaopen(motion_region, min_size);

% 取反：静止区域（壁面）作为最终mask
pixel_mask = ~motion_region;
```

### `+mask/motion_automask_Callback.m`
"Generate all"按钮在选择motion模式时的入口回调。调用 `compute_motion_mask()` 后将结果应用到所有帧：
```matlab
pixel_mask = mask.compute_motion_mask();
blocations = bwboundaries(pixel_mask, 'holes');
% 循环应用到每一帧
for i = 1:2:num_frames_process
    masks_in_frame = mask.px_to_rois(blocations, currentframe, masks_in_frame, 'on');
end
```

## 修改的文件

### `+gui/generateUI.m`

**1. 下拉菜单增加选项 (line 240)**
```matlab
% 原来3个选项，新增第4个
'String',{'Bright area mask generator','Dark area mask generator',
          'Low contrast area mask generator', 'Motion-based mask generator',
          'Custom script (coming soon)'}
```

**2. 新增 uipanel25_11 面板 (lines 514-541)**
在Expert模式的遮罩面板中新增"Motion-based mask generator"子面板，包含4个参数编辑框：
- `handles.motion_percentile` — 百分位阈值编辑框
- `handles.motion_frame_interval` — 帧间隔编辑框
- `handles.motion_num_pairs` — 采样帧对数编辑框
- `handles.motion_min_size` — 最小区域面积编辑框

### `+mask/bright_or_dark_Callback.m`
新增第4个选项(Motion)的面板切换逻辑：
```matlab
elseif get(handles.mask_bright_or_dark,'Value')==4
    set (handles.uipanel25_3,'Visible','off')
    set (handles.uipanel25_5,'Visible','off')
    set (handles.uipanel25_7,'Visible','off')
    set (handles.uipanel25_11,'Visible','on')
```
其他选项中新增 `set(handles.uipanel25_11,'Visible','off')` 以隐藏motion面板。

### `+mask/automask_preview_Callback.m`
新增motion模式(Value==4)的预览路由：
```matlab
if get(handles.mask_bright_or_dark,'Value')==4
    pixel_mask=mask.compute_motion_mask();
else
    % 原有逻辑...
end
```

### `+mask/automask_generate_current_Callback.m`
新增motion模式(Value==4)的单帧生成路由：
```matlab
if get(handles.mask_bright_or_dark,'Value')==4
    pixel_mask=mask.compute_motion_mask();
else
    % 原有逻辑...
end
```

### `+mask/automask_generate_all_Callback.m`
新增motion模式(Value==4)的全帧生成路由：
```matlab
if get(handles.mask_bright_or_dark,'Value')==4
    mask.motion_automask_Callback([],[],[]);
    return
end
```

## 使用方法
1. 加载图像序列
2. 进入 Mask 面板 → 切换为 Expert 模式
3. 在下拉菜单选择 "Motion-based mask generator"
4. 调整参数（或使用默认值）
5. 点击 "Preview" 预览效果，或 "Generate for all frames" 应用到所有帧
