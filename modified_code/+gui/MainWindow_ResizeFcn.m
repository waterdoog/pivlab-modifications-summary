function MainWindow_ResizeFcn(hObject, ~)
handles=guihandles(hObject);
originalunits=get(hObject,'units');
set(hObject,'Units','Characters');
Figure_Size = get(hObject, 'Position');
set(hObject,'Units',originalunits);
margin=1.5;
panelwidth=gui.retr('panelwidth');
panelheighttools=gui.retr('panelheighttools');
panelheightpanels=gui.retr('panelheightpanels');
quickwidth=gui.retr('quickwidth');
quickheight=gui.retr('quickheight');

try
	colorbarpos=get(handles.colorbarpos,'value');
catch
	colorbarpos=1;
end

if colorbarpos==1
	width_reduct=0;x_shift=0;
	height_reduct=0;y_shift=0;
else
	posichoice = get(handles.colorbarpos,'String');
	if strcmp(posichoice{get(handles.colorbarpos,'Value')},'EastOutside')
		width_reduct=30;x_shift=0;height_reduct=0;y_shift=0;
	elseif strcmp(posichoice{get(handles.colorbarpos,'Value')},'WestOutside')
		width_reduct=30;x_shift=30;height_reduct=0;y_shift=0;
	elseif strcmp(posichoice{get(handles.colorbarpos,'Value')},'NorthOutside')
		width_reduct=12;x_shift=6;height_reduct=5;y_shift=0;
	else
		width_reduct=12;x_shift=6;height_reduct=5;y_shift=6;
	end
end

try
	set (findobj('-regexp','Tag','multip'), 'position', [0+margin*0.5 Figure_Size(4)-panelheightpanels-margin*0.25 panelwidth panelheightpanels]);
	set (handles.tools, 'position', [0+margin*0.5 0+margin*0.5 panelwidth panelheighttools]);
	set (handles.quick,'Visible','on');
	set (handles.quick, 'position',[0+margin*0.5 0+margin*0.5+panelheighttools+quickheight quickwidth quickheight])
	set (handles.toolprogress,'Visible','on');
	set (handles.toolprogress, 'position',[0+margin*0.5 0+margin*0.5+panelheighttools quickwidth quickheight])
	set (gca, 'position', [x_shift+panelwidth+margin y_shift+margin Figure_Size(3)-panelwidth-margin-width_reduct Figure_Size(4)-quickheight-height_reduct]);
catch ME
	disp('PIVLAB: Unexpected figure resize behaviour. Please report this issue here:')
	disp('https://groups.google.com/forum/#!forum/pivlab ')
	disp(ME)
end
