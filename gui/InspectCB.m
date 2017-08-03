function InspectCB(action)

% Contains all the callbacks of the objects on InpsectGUI GUI:
%   Previous - plot the previous data set and the index number specified
%              by 'Number' minus one.
%   Next - plot the next data set and the index number specified by 
%          'Number' plus one.
%   Number - plot the data set indicated by the index number which is
%            specified by 'Number'.
%   Quit - delete the figure 'PlotOptions' if any, and delete the
%          current figure.
%   Load - load a data file and create the respective data object.
%   PlotOptions - create a PlotOptions GUI object for the user to modify
%                 the plot options of the plot.


switch(action)
    case 'Previous' 
        s = get(gcbf,'UserData');
        [n,s.ev] = Decrement(s.ev);
        
    case 'Next'
        s = get(gcbf,'UserData');
        [n,s.ev] = Increment(s.ev);
        
    case 'Number'
        s = get(gcbf,'UserData');
        % get string
        str = get(gcbo,'String');
        % try converting string to number
        n = str2num(str);
        % if not a number, try searching for first index that matches
        if(isempty(n))
            % check if str starts with 's:' which indicates a search string
            if(strncmpi('s:',str,2))
                n = name2index(s.obj{1},sscanf(str,'s: %s'),s.optArgs{1}{:});
            else
                n = name2index(s.obj{1},str,s.optArgs{1}{:});
            end
        end			        	
        [s.ev,n] = SetEventNumber(s.ev,n);
        
    case 'Quit'
        s = get(gcbf, 'UserData');
        if isfield(s,'PlotOptions') & ishandle(s.PlotOptions)
            plotOptHandles = guidata(s.PlotOptions);
            if isfield(plotOptHandles, 'objEdit')
                ObjectEditCB('Quit', plotOptHandles.objEdit);
                plotOptHandles = rmfield(plotOptHandles, 'objEdit');
                guidata(s.PlotOptions, plotOptHandles);
            end
            delete(s.PlotOptions);
        end
        delete(gcbf);
        return
        
    case 'Load'
        [filename,path] = uigetfile('*.*','Select data file');
        if(filename~=0)
            cd(path);
            obj = CreateDataObject(filename);
        end
        
    case 'PlotOptions'
        H=gcbf;
        s = get(H,'UserData');
        if isfield(s,'PlotOptions') & ishandle(s.PlotOptions)
            set(s.PlotOptions, 'Visible', 'on');
        else
            h = PlotOptions(H,s);
            s.PlotOptions=h;
            
            set(H, 'UserData', {});
            set(H,'UserData',s)
        end
        return
end

InspectFn (gcbf, n);

edithandle = findobj(gcbf,'Tag','EditText1');
set(edithandle,'String',num2str(n));

set(gcbf, 'UserData', {});
set(gcbf,'UserData',s);