function histInspectCB(action)

switch(action)
    case 'Load'
        [filename,path] = uigetfile('*.*','Select data file');
        if(filename~=0)
            cd(path);
            obj = CreateDataObject(filename);
        end
    case 'Recompute'
        %get parameters (bin_length and axis width)
        h=gcbf;
        h1=findobj(h,'Tag','bin_length_editbox');
        histogram.bin_length = str2num(get(h1,'String'));
        h1=findobj(h,'Tag','time_start_Editbox');
        histogram.time_start = str2num(get(h1,'String'));
        h1=findobj(h,'Tag','time_stop_Editbox');
        histogram.time_stop = str2num(get(h1,'String'));
        h1=findobj(h,'Tag','AxisListbox');
        histogram.axis_num = get(h1,'Value');
        
        %get data
        s=get(h,'UserData');
        eval([char(s.functionname) '(s.data,histogram)'])
        
        
    case 'Quit'
        close(gcbf)
end

