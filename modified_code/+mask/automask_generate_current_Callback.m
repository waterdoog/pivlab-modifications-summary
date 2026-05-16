function automask_generate_current_Callback (~,~,~)
filepath=gui.retr('filepath');
if size(filepath,1) > 1
	handles=gui.gethand;
	selected=2*floor(get(handles.fileselector, 'value'))-1;

	if get(handles.mask_bright_or_dark,'Value')==4
		pixel_mask=mask.compute_motion_mask();
		if get(handles.motion_bubble_size_chk,'Value')
			max_obj_size = str2double(get(handles.motion_bubble_size,'String'));
			if isnan(max_obj_size) || max_obj_size < 1; max_obj_size = 800; end
			smooth_pctl = str2double(get(handles.motion_contrast_pct,'String'));
			if isnan(smooth_pctl) || smooth_pctl <= 0 || smooth_pctl >= 100; smooth_pctl = 20; end
			use_clahe = get(handles.motion_contrast_pct_chk,'Value');
			bubble_dilate = str2double(get(handles.motion_bubble_dilate,'String'));
			if isnan(bubble_dilate) || bubble_dilate < 0; bubble_dilate = 5; end

			[~,piv_image_A]=import.get_img(selected);
			[~,piv_image_B]=import.get_img(selected+1);
			if size(piv_image_A,3)>1
				piv_image_A = rgb2gray(piv_image_A);
			end
			if size(piv_image_B,3)>1
				piv_image_B = rgb2gray(piv_image_B);
			end
			frame_img = im2double(piv_image_A)/2 + im2double(piv_image_B)/2;
			if use_clahe
				frame_img = adapthisteq(frame_img, 'ClipLimit', 0.02);
			end
			flow_region = ~pixel_mask;
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
			if get(handles.motion_max_objects_chk,'Value')
				max_objects = round(str2double(get(handles.motion_max_objects,'String')));
				if isnan(max_objects) || max_objects < 1; max_objects = 1; end
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
			if get(handles.motion_bubble_dilate_chk,'Value') && bubble_dilate > 0
				SE = strel('disk', bubble_dilate);
				detected = imdilate(detected, SE);
			end
			pixel_mask = pixel_mask | detected;
		end
	else
		mask_generator_settings=mask.get_mask_generator_settings();
		[~,piv_image_A]=import.get_img(selected);
		[~,piv_image_B]=import.get_img(selected+1);
		if size(piv_image_A,3)>1
			piv_image_A = rgb2gray(piv_image_A);
			piv_image_B = rgb2gray(piv_image_B);
		end
		pixel_mask=mask.pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings);
	end
	blocations = bwboundaries(pixel_mask,'holes');
	currentframe=floor(get(handles.fileselector, 'value'));
	masks_in_frame=gui.retr('masks_in_frame');
	masks_in_frame{currentframe}=[];
	masks_in_frame=mask.px_to_rois(blocations,currentframe,masks_in_frame,'on');
	gui.put('masks_in_frame',masks_in_frame);
	mask.redraw_masks
	gui.sliderdisp(gui.retr('pivlab_axis'));
end

