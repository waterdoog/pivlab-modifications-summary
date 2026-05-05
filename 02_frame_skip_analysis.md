# Frame Skip (帧对跳跃) Feature

## 概述
在PIV分析中新增"Frame pair skip"功能，允许用户跳过帧对以减少计算量。例如 skip=2 时，只处理第1、3、5...个帧对，而不是所有帧对。

## 修改的文件

### `+gui/generateUI.m`

**新增UI控件 (Analyze面板 multip05, lines 855-859)**

在"Analyze all frames"按钮和"Refresh display"复选框之间新增：
- `handles.frame_skip_text` — 标签 "Frame pair skip:"
- `handles.frame_skip` — 编辑框，默认值 "1"

```matlab
item=[0 item(2)+item(4)+margin/2 parentitem(3)/2.5 1.5];
handles.frame_skip_text = uicontrol(handles.multip05,'Style','text',
    'String','Frame pair skip:','Units','characters','Fontunits','points',
    'HorizontalAlignment','left','Position',[...],'Tag','frame_skip_text');

item=[parentitem(3)/2.5 item(2) parentitem(3)/5 1.5];
handles.frame_skip = uicontrol(handles.multip05,'Style','edit',
    'String','1','Units','characters','Fontunits','points',
    'Position',[...],'Tag','frame_skip',
    'TooltipString','Skip frame pairs during analysis. 1=process all pairs, 2=every 2nd pair, 3=every 3rd pair, etc.');
```

### `+piv/DCC_and_DFT_analyze_all.m`

**修改1: 并行分析预处理循环 (lines 118-132)**

原来：
```matlab
for i=1:2:num_frames_to_process
    k=(i+1)/2;
    slicedfilepath1{k}=filepath{i};
    ...
end
```

修改后：
```matlab
frame_skip = str2double(get(handles.frame_skip,'String'));
if isnan(frame_skip) || frame_skip < 1
    frame_skip = 1;
end
frame_skip = round(frame_skip);
k=0;
for i=1:2*frame_skip:num_frames_to_process
    k=k+1;
    slicedfilepath1{k}=filepath{i};
    ...
end
```

**修改2: 串行分析主循环 (lines 364-370)**

原来：
```matlab
for i=1:2:num_frames_to_process
```

修改后：
```matlab
frame_skip_serial = str2double(get(handles.frame_skip,'String'));
if isnan(frame_skip_serial) || frame_skip_serial < 1
    frame_skip_serial = 1;
end
frame_skip_serial = round(frame_skip_serial);
result_idx=0;
for i=1:2*frame_skip_serial:num_frames_to_process
    result_idx=result_idx+1;
    ...
```

**修改3: 结果存储索引**

原来用 `(i+1)/2` 作为结果索引，修改为使用 `result_idx` 计数器：
```matlab
% 原来
resultslist{1,(i+1)/2}=x;
set(handles.fileselector, 'value', (i+1)/2);
set(handles.overall, 'string', ['Total progress: ' int2str((i+1)/2/num_frames_to_process*200) '%'])

% 修改后
resultslist{1,result_idx}=x;
set(handles.fileselector, 'value', result_idx);
num_total_pairs = ceil(num_frames_to_process/2/frame_skip_serial);
set(handles.overall, 'string', ['Total progress: ' int2str(result_idx/num_total_pairs*100) '%'])
```

进度计算和剩余时间估算也相应更新：
```matlab
% 原来
done=(i+1)/2;
tocome=(num_frames_to_process/2)-done;

% 修改后
done=result_idx;
tocome=num_total_pairs-done;
```

### `+piv/ensemble_piv_analyze_all.m`
**未修改** — Ensemble PIV将所有帧对累积到一个相关矩阵中产生单一结果，frame skip概念不适用。

## 使用方法
1. 加载图像序列
2. 配置PIV设置
3. 进入 "Analyze" 面板
4. 在 "Frame pair skip:" 编辑框中输入跳跃值：
   - `1` = 处理所有帧对（默认，与原始行为一致）
   - `2` = 每隔一个帧对处理一次（处理量减半）
   - `3` = 每隔两个帧对处理一次（处理量减为1/3）
5. 点击 "Analyze all frames"

## 注意事项
- 输入值会自动取整（round）并限制最小为1
- 无效输入（NaN、负数）会回退到默认值1
- Mask仍然按原始帧对索引查找，确保正确的遮罩对应关系
- 并行模式(parfor)同样生效，因为sliced数组已经按skip构建
