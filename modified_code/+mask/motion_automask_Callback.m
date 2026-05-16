function motion_automask_Callback(~,~,~)
filepath = gui.retr('filepath');
if size(filepath,1) <= 1
	return;
end

handles = gui.gethand;
gui.toolsavailable(0, 'Computing motion mask...');

pixel_mask = mask.compute_motion_mask();

obj_detect_enabled = get(handles.motion_bubble_size_chk,'Value');
max_obj_size = str2double(get(handles.motion_bubble_size,'String'));
if isnan(max_obj_size) || max_obj_size < 1
	max_obj_size = 800;
end
use_clahe = get(handles.motion_contrast_pct_chk,'Value');
smooth_pctl = str2double(get(handles.motion_contrast_pct,'String'));
if isnan(smooth_pctl) || smooth_pctl <= 0 || smooth_pctl >= 100
	smooth_pctl = 20;
end
limit_objects = get(handles.motion_max_objects_chk,'Value');
max_objects = round(str2double(get(handles.motion_max_objects,'String')));
if isnan(max_objects) || max_objects < 1
	max_objects = 1;
end
do_dilate = get(handles.motion_bubble_dilate_chk,'Value');
bubble_dilate = str2double(get(handles.motion_bubble_dilate,'String'));
if isnan(bubble_dilate) || bubble_dilate < 0
	bubble_dilate = 5;
end

gui.put('masks_in_frame', []);

if gui.retr('video_selection_done') == 0
	num_frames_process = size(filepath, 1);
else
	video_frame_selection = gui.retr('video_frame_selection');
	num_frames_process = numel(video_frame_selection);
end

flow_region = ~pixel_mask;

for i = 1:2:num_frames_process
	currentframe = (i + 1) / 2;

	if obj_detect_enabled
		[~, img_A] = import.get_img(i);
		[~, img_B] = import.get_img(i+1);
		if size(img_A, 3) > 1
			img_A = rgb2gray(img_A);
		end
		if size(img_B, 3) > 1
			img_B = rgb2gray(img_B);
		end
		frame_img = im2double(img_A)/2 + im2double(img_B)/2;
		if use_clahe
			frame_img = adapthisteq(frame_img, 'ClipLimit', 0.02);
		end
		close_radius = round(sqrt(max_obj_size) / 2);
		inner_flow = imerode(flow_region, strel('disk', close_radius));
		local_std = stdfilt(frame_img, ones(9));
		flow_std = local_std(inner_flow);
		smooth_thresh = prctile(flow_std(:), smooth_pctl);
		smooth_regions = local_std <= smooth_thresh & inner_flow;
		SE_close = strel('disk', close_radius);
		smooth_regions = imclose(smooth_regions, SE_close);
		smooth_regions = imfill(smooth_regions, 'holes');
		detected = bwareaopen(smooth_regions, max_obj_size);
		if limit_objects
			CC = bwconncomp(detected);
			if CC.NumObjects > max_objects
				region_areas = cellfun(@numel, CC.PixelIdxList);
				[~, sorted_idx] = sort(region_areas, 'descend');
				keep_idx = sorted_idx(1:max_objects);
				detected = false(size(detected));
				for obj_k = 1:max_objects
					detected(CC.PixelIdxList{keep_idx(obj_k)}) = true;
				end
			end
		end
		if do_dilate && bubble_dilate > 0
			SE = strel('disk', bubble_dilate);
			detected = imdilate(detected, SE);
		end
		frame_mask = pixel_mask | detected;
	else
		frame_mask = pixel_mask;
	end

	blocations = bwboundaries(frame_mask, 'holes');
	masks_in_frame = gui.retr('masks_in_frame');
	masks_in_frame = mask.px_to_rois(blocations, currentframe, masks_in_frame, 'on');
	gui.put('masks_in_frame', masks_in_frame);
	gui.update_progress(round(i / num_frames_process * 100));
end

mask.redraw_masks;
gui.update_progress(0);
gui.toolsavailable(1);
gui.sliderdisp(gui.retr('pivlab_axis'));

end
