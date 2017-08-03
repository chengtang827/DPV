function varargout = ObjectCB(varargin)

if nargin < 2
    handles = guidata(gcbf);
else
    handles = guidata(varargin{2});
    handles.output = varargin{2};
end

if ~isempty(varargin) & ischar(varargin{1})
    lable = varargin{1};
else
    lable = get(gcbo, 'Tag');
end

switch lable
    case 'Directory'
        dataDirectory = [prefdir filesep 'dirObjAndDirList'];
        
        % get the object names in each directory
        listDirName = get(gcbo, 'String');
        currentDirName = listDirName{get(gcbo, 'Value')};
        load (dataDirectory);
        listObjName = eval(['dirObjList.' currentDirName]);
        
        set (handles.Object, 'Value', []);
        if isfield(handles, 'conOpt')
            delete(handles.conOpt);
            handles = rmfield(handles, 'conOpt');
        end
        set (handles.Object, 'String', listObjName);
        
        % update handles of gcf
        guidata(gcf, handles);
        
        clear dirList dirObjList
        
        
    case 'Object'
        % get the current object name in the object list
        listObjName = get(handles.Object, 'String');
        currentObjName = listObjName{get(handles.Object, 'Value')};
        
        conArgs = {};
        plotArgs = {};
        % get the object and constructor arguments
        if ~isempty(varargin) & ischar(varargin{1})
            optArgs = eval(['{' varargin{3} '}']);
            if length(optArgs) > 0
                plotArgs = optArgs{1};
                if length(optArgs) > 1
                    conArgs = optArgs{2};
                end
            end
        end
        try
            [currentObj, conArgs] = feval (currentObjName, 'ArgsOnly', conArgs{:});
        catch
            display(['Error: please add the argument ''ArgsOnly'' to the ' ...
                     ' constructor function of ' currentObjName '! Refer to @dirfiles/dirfiles.']);
        end
        
        % get constructor arguments structure
        conArgs =conArgs{2};
        
        % *************** Constructor Options *****************************
        
        % initiate constructor options panel
        if isfield(handles, 'conOpt')
            delete (handles.conOpt);
            handles = rmfield (handles, 'conOpt');
        end

        % create panel for Constructor Options
        hConOpt = uipanel ('Parent',gcf, 'Units','characters', 'Tag','Constructor', ...
                           'Position',[49.8 5.6923076923076925 90.0 32.69230769230769], ...
                           'BorderType','line', 'HighlightColor',[0 0 0]);
        % add hConOpt to handles
        handles.conOpt = hConOpt;
        % update gcf
        guidata(handles.output, handles);
        
        conPos = get(hConOpt, 'Position');
        height = conPos(4);
        wid = conPos(3);

        [vert, handlesCollect] = optionsGUI (hConOpt, conArgs, 1, 1);
        set(handles.conOpt, 'UserData', {});
        set(handles.conOpt, 'UserData', handlesCollect);

        % create a scrolling bar for the panel if necessary
        if vert < 0
            sldrPos = [.95*wid, 0, .05*wid, height];
            sldrMax = 0;
            sldrMin = (vert-.05)*height;
            h_sldrPlot = uicontrol ('Parent',handles.plotOpt, 'Style','slider', ...
                                'Units','characters', 'Tag','sldr', ...
                                'Callback', ['sldrCB (', ...
                                num2str(handles.conOpt, '%.13f'), ')'], ...
                                'Position',sldrPos, 'Min',sldrMin, 'Max',sldrMax, ...
                                'SliderStep',[0.1 0.5], 'Value',0);
        end
        
          
        % *************** End Constructor Options *************************
        
        
        % check if Plot Options is needed to plot
        if ~isfield (handles, 'parFig')
            % enable the Process popupmenu
            hProcess = findobj(gcf, 'Tag', 'Process');
            processStr = get(hProcess, 'String');
            set(hProcess, 'String', processStr);
            set(hProcess, 'Value', 1);
            set(hProcess, 'Enable', 'on');
            handles.vert = vert;
            % update handles of gcf
            guidata(gcf, handles)
            return;
        end
        
        
        % get plot options arguments structure
        try
            [currentObj, plotArgs] = feval (@plot, currentObj, 'ArgsOnly', plotArgs{:});
        catch
            display(['Error: please add the argument ''ArgsOnly'' to the' ...
                     'respective plot function! Refer to @dirfiles/PLOT.']);
        end
        plotArgs = plotArgs{2};
        
        % *************** Plot Options ************************************
        % initiate plot options panel
        if isfield(handles, 'plotOpt')
            delete (handles.plotOpt);
            handles = rmfield (handles, 'plotOpt');
        end

        % create panel for Plot Options
        hPlotOpt = uipanel ('Parent',gcf, 'Units','characters', ...
                           'Position',[139.6 5.6923076923076925 90.0 32.69230769230769], ...
                           'BorderType','line', 'HighlightColor',[0 0 0]);
        % add hPlotOpt to handles
        handles.plotOpt = hPlotOpt;
        % update gcf
        guidata(handles.output, handles);
        
        plotPos = get(hPlotOpt, 'Position');
        height = plotPos(4);
        wid = plotPos(3);

        [vert, handlesCollect] = optionsGUI (hPlotOpt, plotArgs, 1, 1);
        set(handles.plotOpt, 'UserData', {});
        set(handles.plotOpt, 'UserData', handlesCollect);
        
            
        % create a slider at the right side of the plot Options panel
        if vert < 0
            sldrPos = [.95*wid-.2, .05, .05*wid, height-.1];
            sldrMax = 0;
            sldrMin = (vert-.05)*height;
            h_sldrPlot = uicontrol ('Parent',handles.plotOpt, 'Style','slider', ...
                                    'Units','characters', 'Tag','sldr', ...
                                    'Callback', ['sldrCB (', ...
                                    num2str(handles.plotOpt, '%.13f'), ')'], ...
                                    'Position',sldrPos, 'Min',sldrMin, 'Max',sldrMax, ...
                                    'SliderStep',[0.1 0.5], 'Value',0);
        end
        
        handles.vert = vert;
        
        % update handles of gcf
        guidata(gcf, handles)
   
        % *************** End Plot Options ********************************
        
        
    case 'Process'
        handles = guidata(gcf);
        vert = handles.vert;
        conPos = get(handles.conOpt, 'Position');
        height = conPos(4);
        wid = conPos(3);
        
        % clear the previous Process options on the constructor panel
        handlesCollect = get(handles.conOpt, 'UserData');
        handlesData = handlesCollect{1};
        handlesPos = handlesCollect{2};
        processInd = length(handlesData)+1;
        for ii = 1:length(handlesData)
            if strcmp(get(handlesData(ii), 'Tag'), 'processName')
                processInd = ii;
                break;
            else
                newHandlesData(ii) = handlesData(ii);
                newHandlesPos{ii} = handlesPos{ii};
            end
        end
        % change the value of vert if there is previous Process options
        if processInd < length(handlesData)+1
            vert = handlesPos{processInd}(2)/height + .055;
        end
        % delete the options from the mark
        for ii = processInd:length(handlesData)
            delete (handlesData(ii));
        end
        % update the handlesCollect
        handlesCollect = {newHandlesData, newHandlesPos};
        set(handles.conOpt, 'UserData', {});
        set(handles.conOpt, 'UserData', handlesCollect);
        
        % plot the new Process options
        procStr = get(gcbo, 'String');
        indLevels = get(gcbo, 'Value');
        % get the current process level
        procName = procStr{indLevels};
        procName = ['Process' procName];
        % get the current object
        hObj = findobj(gcf, 'Tag', 'Object');
        listObjName = get(hObj, 'String');
        currentObjName = listObjName{get(hObj, 'Value')};
        try
            currentObj = feval(currentObjName,'ArgsOnly');
        catch
            display(['Error: please add the argument ''ArgsOnly'' to the' ...
                     'respective constructor function! Refer to @dirfiles/dirfiles.']);
        end
        % check whether the current process level is valid
        if indLevels < 5 & indLevels ~= 3
            return;
        elseif indLevels == 3
            % plot the title
            vert = vert - .055;
            hTitle = uicontrol('Parent',handles.conOpt, 'Units','characters', ...
                               'Position',[.01*wid vert*height .33*wid .03*height], ...
                               'FontUnits','normalized', 'FontSize',.9, 'FontWeight','bold', ...
                               'Style','text', 'Tag','processName', ...
                               'String',[procName ' Options:']);
            if vert < 0
                set(hTitle, 'Visible', 'off');
            end
            handlesCollect = get(handles.conOpt, 'UserData');
            handlesCollect{1} = [handlesCollect{1}, hTitle];
            handlesCollect{2}{length(handlesCollect{2})+1} = get(hTitle, 'Position');
            set(handles.conOpt, 'UserData', {});
            set(handles.conOpt, 'UserData', handlesCollect);
            % get and plot the arguments on the process levels
            [procObj, procArgs] = ProcessDirs(currentObj, 'ArgsOnly');
            procArgs = procArgs{2};
            procArgs = rmfield(procArgs, 'Object');
            vert = vert - .045;
            [vert, handlesCollect] = optionsGUI (handles.conOpt, procArgs, 1, vert);
            conHandlesCollect = get(handles.conOpt, 'UserData');
            conHandlesData = conHandlesCollect{1};
            conHandlesPos = conHandlesCollect{2};
            handlesCollect{1} = [conHandlesData, handlesCollect{1}];
            handlesCollect{2} = {conHandlesPos{:}, handlesCollect{2}{:}};
            set(handles.conOpt, 'UserData', {});
            set(handles.conOpt, 'UserData', handlesCollect);
            
            % create a popupmenu for user to choose an object
            vert = vert -.1;
            hObjChoice = uicontrol('Parent',handles.conOpt, 'Style','popupmenu', ...
                                   'Units','characters', 'Tag','objChoice', ...
                                   'FontUnits','normalized', 'FontSize',.6, ...
                                   'Position',[.6*wid, vert*height, .32*wid, .045*height], ...
                                   'String', {'Choose an object ...'});
            objChoiceStr = {'Choose an object ...', '--------------------'};
            varList = evalin('base', 'whos');
            numVar = length(varList);
            for ii = 1:numVar
                if strcmp(varList(ii).class, 'nptdata')
                    objChoiceStr = {objChoiceStr{:}, varList(ii).name};
                end
            end
            set (hObjChoice, 'String', objChoiceStr);
            clear varList;
            vert = vert - .05;
            handlesCollect = get(handles.conOpt, 'UserData');
            handlesCollect{1} = [handlesCollect{1}, hObjChoice];
            handlesCollect{2}{length(handlesCollect{2})+1} = get(hObjChoice, 'Position');
            set(handles.conOpt, 'UserData', {});
            set(handles.conOpt, 'UserData', handlesCollect);
            % save the handles
            guidata(gcf, handles);
            % delete the previous slider
            hSldr = findobj(handles.conOpt, 'Tag', 'sldr');
            if ~isempty(hSldr)
                sldrCB (handles.conOpt, 0);
                delete(hSldr);
            end
            % create a slider
            if vert < 0
                sldrPos = [.95*wid-.2, .05, .05*wid, height-.1];
                sldrMax = 0;
                sldrMin = (vert-.05)*height;
                h_sldrPlot = uicontrol ('Parent',handles.conOpt, 'Style','slider', ...
                                        'Units','characters', 'Tag','sldr', ...
                                        'Callback', ['sldrCB (', ...
                                        num2str(handles.conOpt, '%.13f'), ')'], ...
                                        'Position',sldrPos, 'Min',sldrMin, 'Max',sldrMax, ...
                                        'SliderStep',[0.1 0.5], 'Value',0);
            end
            
            return;
        end
        
        % get the current process level
        procName = procStr{indLevels};
        procName = ['Process' procName];
        % get the current object name
        hObj = findobj(gcf, 'Tag', 'Object');
        listObjName = get(hObj, 'String');
        currentObjName = listObjName{get(hObj, 'Value')};
        try
            currentObj = feval(currentObjName,'ArgsOnly');
        catch
            display(['Error: please add the argument ''ArgsOnly'' to the' ...
                     'respective constructor function! Refer to @dirfiles/dirfiles.']);
        end

        % get and plot the arguments on the process levels
        try
            [procObj, procArgs] = feval(procName, currentObj, 'ArgsOnly');
        catch
            display(['Error: please add the argument ''ArgsOnly'' to the' ...
                     'respective constructor function! Refer to @dirfiles/dirfiles.']);
        end

        procArgs = procArgs{2};
        vert = vert - .055;
        hTitle = uicontrol('Parent',handles.conOpt, 'Units','characters', ...
                           'Position',[.01*wid vert*height .33*wid .03*height], ...
                           'FontUnits','normalized', 'FontSize',.9, 'FontWeight','bold', ...
                           'Style','text', 'Tag','processName', ...
                           'String',[procName ' Options:']);
        if vert < 0
            set(hTitle, 'Visible', 'off');
        end
        handlesCollect = get(handles.conOpt, 'UserData');
        handlesCollect{1} = [handlesCollect{1}, hTitle];
        handlesCollect{2}{length(handlesCollect{2})+1} = get(hTitle, 'Position');
        set(handles.conOpt, 'UserData', {});
        set(handles.conOpt, 'UserData', handlesCollect);
        % plot the options
        vert = vert - .05;
        [vert, handlesCollect] = optionsGUI (handles.conOpt, procArgs, 1, vert);
        conHandlesCollect = get(handles.conOpt, 'UserData');
        conHandlesData = conHandlesCollect{1};
        conHandlesPos = conHandlesCollect{2};
        handlesCollect{1} = [conHandlesData, handlesCollect{1}];
        handlesCollect{2} = {conHandlesPos{:}, handlesCollect{2}{:}};
        set(handles.conOpt, 'UserData', {});
        set(handles.conOpt, 'UserData', handlesCollect);
        
        handles.vert = vert;
        % save the handles
        guidata(gcf, handles);
        % delete the previous slider
        hSldr = findobj(handles.conOpt, 'Tag', 'sldr');
        if ~isempty(hSldr)
            sldrCB(handles.conOpt, 0);
            delete(hSldr);
        end
        % create a slider
        if vert < 0
            sldrPos = [.95*wid-.2, .05, .05*wid, height-.1];
            sldrMax = 0;
            sldrMin = (vert-.05)*height;
            h_sldrPlot = uicontrol ('Parent',handles.conOpt, 'Style','slider', ...
                                    'Units','characters', 'Tag','sldr', ...
                                    'Callback', ['sldrCB (', ...
                                    num2str(handles.conOpt, '%.13f'), ')'], ...
                                    'Position',sldrPos, 'Min',sldrMin, 'Max',sldrMax, ...
                                    'SliderStep',[0.1 0.5], 'Value',0);
        end
     
        
    case 'AnalysisLevel'
        handles = guidata(gcf);
        conPos = get(handles.conOpt, 'Position');
        height = conPos(4);
        wid = conPos(3);
        
        hObj = findobj(gcf, 'Tag', 'Object');
        listObjName = get(hObj, 'String');
        currentObjName = listObjName{get(hObj, 'Value')};
        currentObj = feval(currentObjName);
        
        anaLevel = lower(get(gcbo, 'String'));
        objAnaLevel = lower(get(currentObj, 'AnalysisLevel'));
        objLevel = get(currentObj, 'ObjectLevel');
        if strcmp(anaLevel, objAnaLevel)
            return;
        else
            % clear the previous ProcessGroup or ProcessCellCombos options
            % on the constructor panel
            handlesCollect = get(handles.conOpt, 'UserData');
            handlesData = handlesCollect{1};
            handlesPos = handlesCollect{2};
            processInd = length(handlesData);
            vert = handlesPos{processInd}(2) / height;

            % get and plot the arguments on the process levels
            hProcess = findobj(gcf, 'Tag', 'Process');
            if strcmp(anaLevel, 'single')
                procName = 'ProcessLevel';
            else
                procName = 'ProcessCombination';
            end
            conArgs = get(handles.conOpt, 'UserData');
            conArgs = conArgs{1};
            a2 = max(find(ishandle(conArgs)));
            pos1 = strfind(get(conArgs(1:a2), 'String'), 'ProcessLevel Options:');
            for i = 1: length(pos1)
                if(find(pos1{i}))
                    a1 = i;
                end
            end
            procOptions = {};
            numArgs = 0;
            for ai = a1:a2
                if strcmp(get(conArgs(ai), 'Style'), 'checkbox')
                    if get(conArgs(ai), 'Value') == 1
                        numArgs = numArgs+1;
                        temCell2Str = get(conArgs(ai), 'String');
                        procOptions{numArgs} = temCell2Str;
                    end  
                elseif strcmp(get(conArgs(ai), 'Style'), 'edit')
                    if ~isempty(get(conArgs(ai), 'String'))
                        numArgs = numArgs+1;
                        temCell2Str = get(conArgs(ai-1), 'String');
                        procOptions{numArgs} = temCell2Str;
                        numArgs = numArgs+1;
                        if sum(strcmp(temCell2Str, {'Include','Exclude'}))
                            try
                                procOptions{numArgs} = eval(get(conArgs(ai), 'String'));
                            catch
                                try
                                    procOptions{numArgs} = evalin('base', get(conArgs(ai), 'String'));
                                catch
                                    if strcmp(get(conArgs(ai), 'Tag'), 'n')
                                        procOptions{numArgs} = str2num(get(conArgs(ai), 'String'));
                                    else
                                        procOptions{numArgs} = get(conArgs(ai), 'String');
                                    end
                                end
                            end
                        else 
                            if strcmp(get(conArgs(ai), 'Tag'), 'n')
                                procOptions{numArgs} = str2num(get(conArgs(ai), 'String'));
                            else
                                procOptions{numArgs} = get(conArgs(ai), 'String');
                            end
                        end
                    end
                end
            end
            procOptions{numArgs+1} = 'ArgsOnly';
            try
                [procObj, procArgs] = feval(procName, currentObj, procOptions{:});
            catch
                display(['Error: please add the argument ''ArgsOnly'' to the' ...
                         'respective constructor function! Refer to @dirfiles/dirfiles.']);
            end


            procArgs = procArgs{2};
            
            hTitle = uicontrol('Parent',handles.conOpt, 'Units','characters', ...
                               'Position',[.01*wid vert*height-3 .33*wid .03*height], ...
                               'FontUnits','normalized', 'FontSize',.9, 'FontWeight','bold', ...
                               'Style','text', 'Tag','processName', ...
                               'String',[procName ' Options:']);
            if vert < 0
                set(hTitle, 'Visible', 'off');
            end
%             handlesCollect{1} = [newHandlesData, hTitle];
            handlesCollect{1} = [handlesData, hTitle];
            handlesCollect{2}{length(handlesCollect{2})+1} = get(hTitle, 'Position');
            set(handles.conOpt, 'UserData', {});
            set(handles.conOpt, 'UserData', handlesCollect);
            % plot the options
            vert = vert - .05;
%             if(strcmp(iistr,'ProcessCellCombos Options:'))
%                 [vert, handlesCollect] = optionsGUI (handles.conOpt, procArgs, 1, vert,0);
%             else
                [vert, handlesCollect] = optionsGUI (handles.conOpt, procArgs, 1, vert);
%             end
            conHandlesCollect = get(handles.conOpt, 'UserData');
            conHandlesData = conHandlesCollect{1};
            conHandlesPos = conHandlesCollect{2};
            handlesCollect{1} = [conHandlesData, handlesCollect{1}];
            handlesCollect{2} = {conHandlesPos{:}, handlesCollect{2}{:}};
            set(handles.conOpt, 'UserData', {});
            set(handles.conOpt, 'UserData', handlesCollect);

            handles.vert = vert;
            % save the handles
            guidata(gcf, handles);
            % delete the previous slider
            hSldr = findobj(handles.conOpt, 'Tag', 'sldr');
            sldrVal = 0;
            if ~isempty(hSldr)
                sldrVal = get(hSldr, 'Value');
                delete(hSldr);
            end                
            % create a slider
            if vert < 0
                sldrPos = [.95*wid-.2, .05, .05*wid, height-.1];
                sldrMax = 0;
                sldrMin = (vert-.05)*height;
                h_sldrPlot = uicontrol ('Parent',handles.conOpt, 'Style','slider', ...
                                        'Units','characters', 'Tag','sldr', ...
                                        'Callback', ['sldrCB (', ...
                                        num2str(handles.conOpt, '%.13f'), ')'], ...
                                        'Position',sldrPos, 'Min',sldrMin, 'Max',sldrMax, ...
                                        'SliderStep',[0.1 0.5], 'Value',sldrVal);
                sldrCB(handles.conOpt, sldrVal);
            else
                sldrCB(handles.conOpt, 0);
            end
            
        end 
           
        
    case 'dirHistory'
        dirList = get(gcbo, 'String');
        dirInd = get(gcbo, 'Value');
        cd(dirList{dirInd});
        if dirInd > 1
            if dirInd < length(dirList)
                dirList = {dirList{dirInd}, dirList{1:(dirInd-1)}, dirList{(dirInd+1):end}};
            else
                dirList = {dirList{dirInd}, dirList{1:(dirInd-1)}};
            end
        end
        set (gcbo, 'String', dirList);
        set (gcbo, 'Value', 1);
        
        
    case 'dirGet'   
        dataDirectory = [prefdir filesep 'dirObjAndDirList'];
        
        load (dataDirectory);
        
        dirString = uigetdir;
        if dirString == 0
            return;
        end
        repeatInd = 0;
        for ii = 1:length(dirList)
            if strcmp(dirString, dirList{ii})
                repeatInd = ii;
                break;
            end
        end
        
        if repeatInd
            while repeatInd ~= 1
                dirList{repeatInd} = dirList{repeatInd-1};
                repeatInd = repeatInd - 1;
            end
            dirList{1} = dirString;
        else
            dirList = {dirString, dirList{:}};
        end

        save (dataDirectory, 'dirList', 'dirObjList');
        
        hDirHis = findobj(gcf, 'Tag', 'dirHistory');
        set (hDirHis, 'String', dirList);
        cd(dirString);
        set (hDirHis, 'Value', 1);
        clear dirList dirObjList;
        
        
    case 'pwdGet'
        dataDirectory = [prefdir filesep 'dirObjAndDirList'];
        
        load (dataDirectory);
        
        dirString = pwd;
        repeatInd = 0;
        for ii = 1:length(dirList)
            if strcmp(dirString, dirList{ii})
                repeatInd = ii;
                break;
            end
        end
        if repeatInd
            while repeatInd ~= 1
                dirList{repeatInd} = dirList{repeatInd-1};
                repeatInd = repeatInd - 1;
            end
            dirList{1} = dirString;
        else
            dirList = {dirString, dirList{:}};
        end

        save (dataDirectory, 'dirList', 'dirObjList');        
        
        hDirHis = findobj(gcf, 'Tag', 'dirHistory');
        set (hDirHis, 'String', dirList);
        clear dirList dirObjList;
        
        
    case 'dirDelete'
        % check whether user choose a directory or not
        hDir = findobj(gcf, 'Tag', 'Directory');
        listDirName = get(hDir, 'String');
        listDirInd = get(hDir, 'Value');
        try
            if ~ischar(listDirName{listDirInd})
                return;
            end
        catch
            return;
        end
        % confirm whether user wants to delete the selected directory
        sureStr = questdlg('Are you sure to delete the selected directory, please?');
        if sum(strcmp(sureStr, {'No','Cancel'}))
            return;
        end

        hObj = findobj(gcf, 'Tag', 'Object');
        set (hObj, 'String', {});
        if isfield(handles, 'conOpt')
            delete(handles.conOpt);
            handles = rmfield(handles, 'conOpt');
        end
        if isfield(handles, 'plotOpt')
            delete(handles.plotOpt);
            handles = rmfield(handles, 'plotOpt');
        end

        newListDirName = {};
        newListDirName = {listDirName{1:(listDirInd-1)}, listDirName{(listDirInd+1):length(listDirName)}};

        set(hDir, 'Value', []);
        set(hDir, 'String', newListDirName);       

        dataDirectory = [prefdir filesep 'dirObjAndDirList'];

        load (dataDirectory);
        listDirName = fieldnames(dirObjList);
        dirObjList = rmfield(dirObjList, listDirName{listDirInd});
        save (dataDirectory, 'dirList', 'dirObjList');
        
        
    case 'dirAdd'
        newDirNameStr = uigetdir;
        if newDirNameStr == 0
            return;
        end
        newDirName = '';
        slash = 0;
        for ii = 1:length(newDirNameStr)
            if sum(strcmp(newDirNameStr(ii), {'\','/'}))
                slash = ii;
            end
        end
        newDirName = newDirNameStr((slash+1):length(newDirNameStr));        
            
        if isfield(handles, 'conOpt')
            delete(handles.conOpt);
            handles = rmfield(handles, 'conOpt');
        end
        if isfield(handles, 'plotOpt')
            delete(handles.plotOpt);
            handles = rmfield(handles, 'plotOpt');
        end
        
        listDirName = get(handles.Directory, 'String');
        listDirName = {listDirName{:}, newDirName};
        set (handles.Directory, 'String', listDirName);
        set (handles.Directory, 'Value', length(listDirName));
        listObj = nptDir([newDirNameStr '\@*']);
        % user may use a different platform from windows, e.g. Unix
        % then we need to check the forward slash
        if isempty(listObj)
            listObj = nptDir([newDirNameStr '/@*']);
        end
        
        if ~isempty(listObj)
            listObjName = {listObj.name};
        else
            listObjName = {};
        end
        for ii = 1:length(listObjName)
            listObjName{ii} = strrep(listObjName{ii}, '@', '');
        end
        hObj = findobj(gcf, 'Tag', 'Object');
        set(hObj, 'String', listObjName);
        set(hObj, 'Value', []);

        dataDirectory = [prefdir filesep 'dirObjAndDirList'];
        load (dataDirectory);
        eval(['dirObjList.' newDirName '=listObjName;']);
        save (dataDirectory, 'dirList', 'dirObjList');        
        
        
    case 'Done'
        % get the constructor arguments
        conArgs = get(handles.conOpt, 'UserData');
        conArgs = conArgs{1};

        hObj = findobj (gcf, 'Tag', 'Object')';
        listObjName = get(hObj, 'String');
        objName = listObjName{get(hObj, 'Value')};
        
        if ~isfield(handles, 'parFig')
            for ii = 1:length(conArgs)
                if strcmp(get(conArgs(ii), 'Tag'), 'processName')
                    conNum = ii-1;
                    break;
                end
            end
            try
                isempty(conNum);
            catch
                conNum = length(conArgs);
            end
            % get the process string and level
            hProcess = findobj (gcf, 'Tag', 'Process');
            procStr = get(hProcess, 'String');
            indLevels = get(hProcess, 'Value');
            % get the variable name
            hNameEdit = findobj (gcf, 'Tag', 'Name');
            varNameList = get (hNameEdit, 'String');
            %***********************************************
            token = cell(1,2);
            if(strmatch('[',varNameList))
                for ii = 1:2
                    [token{ii},varNameList] = strtok(varNameList,'[, ]');
                end
                varName = token{1};
                datavarName = token{2};
            else
                varName = varNameList;
                datavarName = '';
            end
            % get the constructor options
            conOptions = {};
            numArgs = 0;
            for ii = 1:conNum
                if strcmp(get(conArgs(ii), 'Style'), 'checkbox')
                    if get(conArgs(ii), 'Value') == 1
                        numArgs = numArgs+1;
                        temCell2Str = get(conArgs(ii), 'String');
                        conOptions{numArgs} = temCell2Str;
                    end  
                elseif strcmp(get(conArgs(ii), 'Style'), 'text')
                    if strcmp(get(conArgs(ii+1), 'Style'), 'edit')
                        if ~isempty(get(conArgs(ii+1), 'String'))
                            numArgs = numArgs+1;
                            temCell2Str = get(conArgs(ii), 'String');
                            conOptions{numArgs} = temCell2Str;
                            numArgs = numArgs+1;
                            if strcmp(get(conArgs(ii+1), 'Tag'), 'n')
                                conOptions{numArgs} = str2num(get(conArgs(ii+1), 'String'));
                            else
                                conOptions{numArgs} = get(conArgs(ii+1), 'String');
                            end
                        end
                    end
                end
            end
            % get the options for process
            procOptions = {};
            numArgs = 0;
            for ii = (conNum+1):length(conArgs)
                if strcmp(get(conArgs(ii), 'Style'), 'checkbox')
                    if get(conArgs(ii), 'Value') == 1
                        numArgs = numArgs+1;
                        temCell2Str = get(conArgs(ii), 'String');
                        procOptions{numArgs} = temCell2Str;
                    end  
                elseif strcmp(get(conArgs(ii), 'Style'), 'edit')
                    if ~isempty(get(conArgs(ii), 'String'))
                        numArgs = numArgs+1;
                        temCell2Str = get(conArgs(ii-1), 'String');
                        procOptions{numArgs} = temCell2Str;
                        numArgs = numArgs+1;
                        if sum(strcmp(temCell2Str, {'Include','Exclude','nptLevelCmd'}))
                            try
                                procOptions{numArgs} = eval(get(conArgs(ii), 'String'));
                            catch
                                try
                                    procOptions{numArgs} = evalin('base', get(conArgs(ii), 'String'));
                                catch
                                    if strcmp(get(conArgs(ii), 'Tag'), 'n')
                                        procOptions{numArgs} = str2num(get(conArgs(ii), 'String'));
                                    else
                                        procOptions{numArgs} = get(conArgs(ii), 'String');
                                    end
                                end
                            end
                        else 
                            if strcmp(get(conArgs(ii), 'Tag'), 'n')
                                procOptions{numArgs} = str2num(get(conArgs(ii), 'String'));
                            else
                                procOptions{numArgs} = get(conArgs(ii), 'String');
                            end
                        end
                    end
                end
            end
            pL1 = 0;
            for ci = 1:numArgs
                if(~iscell(procOptions{ci}))
                    if(~isempty(findstr(procOptions{ci}, 'Levels')))
                        pL1 = pL1 + 1;
                        pL = ci;
                    end
                end
            end
            try
                if pL1==2
                    procOptions{pL} = [];
                    procOptions{pL+1} = [];
                end
            catch
                procOptions = procOptions;
            end
            varVal = feval(objName);

            if indLevels == 5
                procName = ['Process' procStr{indLevels}];
                [varVal,datavarVal] = feval(procName, varVal, conOptions{:}, procOptions{:});
                assignin ('base', varName, varVal);
                if(~isempty(datavarName))
                    assignin ('base', datavarName, datavarVal);
                end
            elseif indLevels == 3
                hObjChoice = findobj(handles.conOpt, 'Tag', 'objChoice');
                objChoiceStr = get(hObjChoice, 'String');
                objChoiceName = objChoiceStr(get(hObjChoice, 'Value'));
                try
                    objChoice = evalin('base', objChoiceName{1});
                catch
                    display('Please choose an object.');
                end
                [objChoice, varVal] = feval('ProcessDirs',objChoice, 'Object',objName,conOptions{:}, procOptions{:});
                assignin ('base', varName, varVal);
            elseif indLevels == 1
                numCon = length(conOptions);
                conOptions{numCon+1} = 'Auto';
                varVal = feval(objName, conOptions{:});
                assignin ('base', varName, varVal);
            end
        
        else
            % constructor options string
            conOptStr = '';
            for ii = 1:length(conArgs)
                if strcmp(get(conArgs(ii), 'Style'), 'checkbox')
                    if get(conArgs(ii), 'Value') == 1
                        temCell2Str = get(conArgs(ii), 'String');
                        conOptStr = [conOptStr '''' temCell2Str ''', '];
                    end  
                elseif strcmp(get(conArgs(ii), 'Style'), 'edit')
                    if ~isempty(get(conArgs(ii), 'String'))
                        temCell2Str = get(conArgs(ii-1), 'String');
                        conOptStr = [conOptStr '''' temCell2Str '''' ', '];
                        if strcmp(get(conArgs(ii), 'Tag'), 'c')
                            conOptStr = [conOptStr '''' get(conArgs(ii), 'String') ''''];
                        else
                            if strcmp(get(conArgs(ii), 'Tag'), 'n')
                                if isempty(str2num(get(conArgs(ii),'String')))
                                    conOptStr = [conOptStr get(conArgs(ii), 'String')];
                                else
                                    conOptStr = [conOptStr '[' get(conArgs(ii),'String') ']'];
                                end
                            else
                                conOptStr = [conOptStr get(conArgs(ii), 'String')];
                            end
                        end
                        conOptStr = [conOptStr ', '];
                    else
                        temCell2Str = get(conArgs(ii-1), 'String');
                        conOptStr = [conOptStr '''' temCell2Str '''' ', ' '''''' ', '];
                    end
                end
            end
            for ii = 1:(length(conOptStr)-2)
                conOptString(ii) = conOptStr(ii);
            end
            
            % plot options string
            plotArgs = get(handles.plotOpt, 'UserData');
            plotArgs = plotArgs{1};
            plotOptStr = '';
            
            for ii = 1:length(plotArgs)
                if strcmp(get(plotArgs(ii), 'Style'), 'checkbox')
                    if get(plotArgs(ii), 'Value') == 1
                        temCell2Str = get(plotArgs(ii), 'String');
                        plotOptStr = [plotOptStr '''' temCell2Str ''', '];
                    end  
                elseif strcmp(get(plotArgs(ii), 'Style'), 'edit')
                    if ~isempty(get(plotArgs(ii), 'String'))
                        temCell2Str = get(plotArgs(ii-1), 'String');
                        plotOptStr = [plotOptStr '''' temCell2Str '''' ', '];
                        if strcmp(get(plotArgs(ii), 'Tag'), 'c')
                            plotOptStr = [plotOptStr '''' get(plotArgs(ii), 'String') ''''];
                        else
                            plotOptStr = [plotOptStr get(plotArgs(ii), 'String')];
                        end
                        plotOptStr = [plotOptStr ', '];
                    end
                end
            end
            for ii = 1:(length(plotOptStr)-2)
                plotOptString(ii) = plotOptStr(ii);
            end
            
            
            % get the string for the object
            objString = ['{' plotOptString '}, {' conOptString '}'];
            
            hObjName = findobj(handles.parFig, 'Tag', 'objName');
            objOptStrList = get(handles.parFig, 'UserData');
            objNameList = get(hObjName, 'String');
            if ~isfield(handles, 'editObjInd')                
                objNameList = {objNameList{:}, objName};
                set(hObjName, 'String', objNameList);
                set(hObjName, 'Value', length(objNameList));
                 
                objOptStrList = {objOptStrList{:}, objString};
            else
                objOptStrList{handles.editObjInd} = objString;               
            end
            
            hObjOpt = findobj(handles.parFig, 'Tag', 'objOpt');
            set(handles.parFig, 'UserData', objOptStrList);
            set(hObjOpt, 'String', objString);
            
            % remove the objectGUI handle from the objectEdit GUI
            objEditHandles = guidata(handles.parFig);
            if isfield(objEditHandles, 'modify')
                objEditHandles = rmfield(objEditHandles, 'modify');
            elseif isfield(objEditHandles, 'add')
                objEditHandles = rmfield(objEditHandles, 'add');
            end
            guidata(handles.parFig, objEditHandles);
            
            close(handles.output);
            figure (handles.parFig);
            
        end
        
        
    case 'Quit'
        if isfield(handles, 'objEdit')
            ObjectEditCB('Quit', handles.objEdit);
        end
        
        if isfield(handles, 'parFig')
            parHandles = guidata(handles.parFig);
            if isfield(parHandles, 'add') & handles.output==parHandles.add
                parHandles = rmfield(parHandles, 'add');
            end
            if isfield(parHandles, 'modify') & handles.output==parHandles.modify
                parHandles = rmfield(parHandles, 'modify');
            end
            guidata(handles.parFig, parHandles);
        end
                
        delete (handles.output);
        
end