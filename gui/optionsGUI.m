function [vert, handlesCollect] = optionsGUI (hObject, hArgs, varargin)

% This function should not be accessed by user.
% 
% This function plots arguments on the parent figure.
%
% The input arguments are:
%   hObject - handle of parent figure.
%   hArgs - cell array of arguments to be plotted
%   varargin{1} is the size ratio which is used to adjust the positions and
%       sizes of the argument objects.
%   varargin{2} is the vert variable which is used to compute the vertical
%       positions of the argument objects.

% plot the plot options on the panel
sizeRatio = varargin{1};
vert = varargin{2};
hPos = get(hObject, 'Position');
height = hPos(4);
wid = hPos(3);

vert = vert - .05*sizeRatio;
vert1 = vert;
vert2 = vert;

if isfield(hArgs,'flags')
    flags = {hArgs.flags};
    hArgs = rmfield(hArgs,'flags');
else
    flags ={};
end

optionNames = fieldnames(hArgs);
numOptions = size(optionNames,1);

hEdit = [];
for jj = 1:numOptions
    hf{jj} = [];
    ho{jj} = [];
    hv{jj} = [];

    %optionName
    value = eval(['hArgs.' optionNames{jj}]);
    if ~sum(strcmp(optionNames{jj}, {'Auto', 'ArgsOnly', 'NumericArguments', ...
                                     'classname', 'matname', 'matvarname', ...
                                     'GroupPlots', 'GroupPlotIndex', ...
                                     'ReturnVars', 'childArgs','UnimportantArgs'}))
        if ~isempty(flags) & sum(strcmp(optionNames{jj},flags{:})) 
            %flag
            hf{jj} = uicontrol('Parent',hObject, 'Units','characters', ...
                               'Position',[.03*wid vert1*height .33*wid .03*height*sizeRatio], ...
                               'FontUnits','normalized', 'FontSize',.9, ...
                               'String',optionNames{jj}, ...
                               'Style','checkbox', 'Value',value);
            if vert1 < 0 | vert1 > 1
                set (hf{jj}, 'Visible', 'off');
            end
            vert1 = vert1 - .055*sizeRatio;
        else
            testNum = 'c';
            if isnumeric(value)
                if isempty(value)
                    value = '';
                else
                    value = num2str(value);
                end
                testNum = 'n';
            end
            %value
            ho{jj} = uicontrol('Parent',hObject, 'Units','characters', ...
                               'Position',[.37*wid vert2*height .3*wid .03*height*sizeRatio], ...
                               'FontUnits','normalized', 'FontSize',.9, ...
                               'String',optionNames{jj}, 'Style','text', ...
                               'HorizontalAlignment','left');
                           
            % for the argument 'Objects' and 'Object'
            if sum (strcmp(optionNames{jj}, {'Objects', 'Object'}))
                hv{jj} = uicontrol('Parent',hObject, 'Units','characters', ...
                                   'Position',[.68*wid vert2*height ...
                                   .25*wid .034*height*sizeRatio], ...
                                   'FontUnits','normalized', 'FontSize',.75, ...
                                   'Style','edit', 'Tag', ['edit' optionNames{jj}]);
                               
                if strcmp(optionNames{jj}, 'Objects')
                    if isempty(hArgs.Objects)
                        objString = '';
                    else
                        objString = cell2str(hArgs.Objects);
                    end
                else
                    if isempty(hArgs.Object)
                        objString = '';
                    else
                        objString = cell2str(hArgs.Object);
                    end
                end
                
                set (hv{jj}, 'String', objString);
                
                vert2 = vert2-.04*sizeRatio;
                hEdit = uicontrol('Parent',hObject, 'Units','characters', ...
                                 'Position',[.75*wid vert2*height .15*wid .035*height*sizeRatio], ...
                                 'FontUnits','normalized', 'FontSize',.8, ...
                                 'Style','pushbutton', 'String','Edit', ...
                                 'Callback',['ObjectEditCB(' num2str(hObject, '%.13f'), ', '...
                                 num2str(hv{jj}, '%.13f'), ')'], ...
                                 'Tag','Edit');
                             
            % for the argument 'AnalysisLevel'
            elseif strcmp(optionNames{jj}, 'AnalysisLevel') && ~strcmp(hArgs.classname, 'ProcessCombination')
%                 if(strcmp(optionNames{jj-1}, 'AnalysisRelation'))
%                 if(length(varargin) == 2)
                    hv{jj} = uicontrol('Parent', hObject, 'Units','characters', ...
                            'Position',[.68*wid vert2*height .25*wid .034*height*sizeRatio], ...
                            'FontUnits','normalized', 'FontSize',.8, ...
                            'String',value, 'Style','edit', 'Tag','AnalysisLevel', ...
                            'Callback','ObjectCB');
%                 elseif(length(varargin) == 3)
%                     if(varargin{3} == 1)
%                         hv{jj} = uicontrol('Parent', hObject, 'Units','characters', ...
%                             'Position',[.68*wid vert2*height ...
%                             .25*wid .034*height*sizeRatio], ...
%                             'FontUnits','normalized', 'FontSize',.8, ...
%                             'String',value, 'Style','edit', 'Tag','AnalysisLevel', ...
%                             'Callback','ObjectCB');
%                     else
%                         hv{jj} = uicontrol('Parent', hObject, 'Units','characters', ...
%                             'Position',[.68*wid vert2*height ...
%                             .25*wid .034*height*sizeRatio], ...
%                             'FontUnits','normalized', 'FontSize',.8, ...
%                             'String',value, 'Style','edit','Callback','ObjectCB');
%                     end
%                 end
            
            else
                hv{jj} = uicontrol('Parent',hObject, 'Units','characters', ...
                                   'Position',[.68*wid vert2*height ...
                                   .25*wid .034*height*sizeRatio], ...
                                   'FontUnits','normalized', 'FontSize',.8, ...
                                   'String',value, 'Style','edit', 'Tag', testNum);                
            end     % end for the edit of the argument 'Objects' and 'Object'
                       
            if vert2 < 0 | vert2 > 1
                set (ho{jj}, 'Visible', 'off');
                set (hv{jj}, 'Visible', 'off');
            end   
            vert2 = vert2 - .055*sizeRatio;
        end
    end
end

if vert1>vert2
    vert = vert2;
else
    vert = vert1;
end

% collect the handlesData
handlesData = [];
for jj = 1:numOptions
    handlesData = [handlesData, hf{jj}, ho{jj}, hv{jj}];
end
handlesData = [handlesData hEdit];

% collect the handlesPos
handlesPos = {};
for jj = 1:length(handlesData)
    handlesPos{jj} = get(handlesData(jj), 'Position');
end

% collect the handlesData and handlesPos
handlesCollect = {handlesData, handlesPos};

% collect the handles for child arguments if any
% if isfield(hArgs, 'childArgs')
%     vert = vert - .055;
%     hTitle = uicontrol('Parent',hObject, 'Units','characters', ...
%                        'Position',[.01*wid vert*height .33*wid .03*height*sizeRatio], ...
%                        'FontUnits','normalized', 'FontSize',.9, 'FontWeight','bold', ...
%                        'Style','text', 'Tag','processName', ...
%                        'String',[hArgs.childArgs{2}.classname ' Options:']);
%     if vert < 0
%         set(hTitle, 'Visible', 'off');
%     end
%     vert = vert - .05;
%     [vert, childHandlesCollect] = optionsGUI (hObject, hArgs.childArgs{2}, sizeRatio, vert);
%     handlesCollect{1} = [handlesData hTitle childHandlesCollect{1}];
%     handlesCollect{2} = {handlesPos{:}, get(hTitle, 'Position'), childHandlesCollect{2}{:}};
% end
