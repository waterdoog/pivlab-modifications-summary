function automask_preview_Callback(~,~,~)
filepath=gui.retr('filepath');
handles=gui.gethand;
if size(filepath,1) > 1
	handles=gui.gethand;
	selected=2*floor(get(handles.fileselector, 'value'))-1;

	[~,piv_image_A]=import.get_img(selected);
	[~,piv_image_B]=import.get_img(selected+1);
	if size(piv_image_A,3)>1
		piv_image_A = rgb2gray(piv_image_A);
		piv_image_B = rgb2gray(piv_image_B);
	end

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

			flow_region = ~pixel_mask;
			frame_img = im2double(piv_image_A)/2 + im2double(piv_image_B)/2;
			if size(frame_img,3) > 1
				frame_img = rgb2gray(frame_img);
			end
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
		pixel_mask=mask.pixel_mask_from_piv_image(piv_image_A,piv_image_B,mask_generator_settings);
	end
	piv_image=im2double(piv_image_A)/2 + im2double(piv_image_B)/2;
	if size(piv_image,3)>1
		piv_image=rgb2gray(piv_image);
	end
	if get(handles.enhance_images, 'Value')
		piv_image=imadjust(piv_image);
	end
	image(cat(3, piv_image, piv_image, piv_image), 'parent',gui.retr('pivlab_axis'), 'cdatamapping', 'scaled');
	hold on;
	colormap('gray');
	axis image
	set(gui.retr('pivlab_axis'),'ytick',[])
	set(gui.retr('pivlab_axis'),'xtick',[])

	alphamap=pixel_mask*0.9;
	alphamap(alphamap>1)=1;
	alphamap(alphamap<0)=0;
	%temporary workaround for bug in R2025 causing slow performance when not using alphadatamapping=scaled
	alphamap(1,1)=0;
	alphamap(end,end)=1;
	image(cat(3, pixel_mask*0.7, pixel_mask*0.1, pixel_mask*0.1), 'parent',gui.retr('pivlab_axis'), 'cdatamapping', 'direct','AlphaData',alphamap,'AlphaDataMapping','scaled');
	hold off
end

