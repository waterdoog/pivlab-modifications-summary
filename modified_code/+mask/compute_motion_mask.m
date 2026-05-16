function pixel_mask = compute_motion_mask()
handles = gui.gethand;
filepath = gui.retr('filepath');

percentile = str2double(get(handles.motion_percentile,'String'));
frame_interval = str2double(get(handles.motion_frame_interval,'String'));
num_pairs = str2double(get(handles.motion_num_pairs,'String'));
min_size = str2double(get(handles.motion_min_size,'String'));
smooth_size = str2double(get(handles.motion_smooth_size,'String'));

if gui.retr('video_selection_done') == 0
	num_frames = size(filepath, 1);
else
	video_frame_selection = gui.retr('video_frame_selection');
	num_frames = numel(video_frame_selection);
end

max_pairs = floor((num_frames - frame_interval) / 2);
if max_pairs < 1
	max_pairs = 1;
end
num_pairs = min(num_pairs, max_pairs);
pair_indices = round(linspace(1, num_frames - frame_interval, num_pairs));

[~, first_img] = import.get_img(1);
if size(first_img, 3) > 1
	first_img = rgb2gray(first_img);
end
motion_map = zeros(size(first_img, 1), size(first_img, 2));
valid_pairs = 0;

for k = 1:numel(pair_indices)
	idx = pair_indices(k);
	idx2 = idx + frame_interval;
	if idx2 > num_frames
		continue;
	end
	[~, img1] = import.get_img(idx);
	[~, img2] = import.get_img(idx2);
	if size(img1, 3) > 1
		img1 = rgb2gray(img1);
	end
	if size(img2, 3) > 1
		img2 = rgb2gray(img2);
	end
	motion_map = motion_map + abs(im2double(img1) - im2double(img2));
	valid_pairs = valid_pairs + 1;
end

if valid_pairs > 0
	motion_map = motion_map / valid_pairs;
end

threshold_val = prctile(motion_map(:), percentile);
motion_region = motion_map >= threshold_val;

SE = strel('disk', smooth_size);
motion_region = imclose(motion_region, SE);
motion_region = imfill(motion_region, 'holes');
if min_size > 0
	motion_region = bwareaopen(motion_region, min_size);
end

pixel_mask = ~motion_region;
