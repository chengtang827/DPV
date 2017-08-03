function varargout = PlotOptions(varargin)
% PLOTOPTIONS M-file for PlotOptions.fig
%      PLOTOPTIONS, by itself, creates a new PLOTOPTIONS or raises the existing
%      singleton*.
%
%      H = PLOTOPTIONS returns the handle to a new PLOTOPTIONS or the handle to
%      the existing singleton*.
%
%      PLOTOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTOPTIONS.M with the given input arguments.
%
%      PLOTOPTIONS('Property','Value',...) creates a new PLOTOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PlotOptions_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PlotOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PlotOptions

% Last Modified by GUIDE v2.5 02-Jun-2006 17:52:39

% Begin initialization code - DO NOT EDIT
% 09/06/2006 edit the gui_Singleton to create multiple PlotOptions window
% if multiple figures are created.
gui_Singleton = 0;

gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PlotOptions_OpeningFcn, ...
    'gui_OutputFcn',  @PlotOptions_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before PlotOptions is made visible.
function PlotOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PlotOptions (see VARARGIN)


ph = varargin{1};    %parent handle
pud = get(ph, 'UserData');  %parent user data



numObjects = size(pud.obj,2);

vert = 1;
height = 46.15384615384615;
wid = 90.0;
sizeRatio = 1;

for ii=1:numObjects
    
    vert = vert - .15;
    vert1 = vert;
    vert2 = vert;
    
    %box
    %title
    if isfield(pud.Arg(ii).Args,'flags')
        flagsCollect{ii} = {pud.Arg(ii).Args.flags};
        pud.Arg(ii).Args = rmfield(pud.Arg(ii).Args,'flags');
    else
        flagsCollect{ii}={};
    end
    optionNames = fieldnames(pud.Arg(ii).Args);
    numOptions = size(optionNames,1);
    
    for jj = 1:numOptions
        %optionName
        if sum(strcmp(optionNames(jj),flagsCollect{ii}{:}))
            %flag
            vert1 = vert1 - .04;
        else
            %value
            vert2 = vert2 - .04;
            
        end
    end
    
    pud.Arg(ii).Args.flags = flagsCollect{ii}{:};
    
    if vert1>vert2
        vert = vert2;
    else
        vert = vert1;
    end
end
vert = vert - .3;
if vert >= 0
    height = (1-vert)*height;
    set (hObject, 'Position', [103.80000000000001 15.153846153846207 wid height]);
    sizeRatio = 1/(1-vert);
end

vert = 1;

% initialize the PlotOptions interface
for ii=1:numObjects
    if ii == 1
        vert = vert-.05*sizeRatio;
    else
        vert = vert - .1;
    end
    ht{ii} = uicontrol('Parent',hObject,'Units','characters', ...
        'Position',[0 vert*height 0.2*wid .027*height*sizeRatio], ...
        'FontUnits','normalized','FontSize',.9, ...
        'FontWeight','bold', ...
        'String',['Object ', num2str(ii), ':'],'Style','text');
    if vert < 0
        set(ht{ii}, 'Visible', 'off');
    end
    
    [vert, handlesCollect{ii}] = optionsGUI(hObject, pud.Arg(ii).Args, sizeRatio, vert);
    
end

% collect the handlesData
handlesData = [];
handlesPos = {};
for ii = 1:numObjects
    handlesData = [handlesData, ht{ii}, handlesCollect{ii}{1}];
    temp = handlesCollect{ii}{2};
    handlesPos = {handlesPos{:} get(ht{ii}, 'Position') temp{:}};
end
handlesCollect = {handlesData, handlesPos};

% create a title for InspectGUI options
vert = vert - .05*sizeRatio;
hff = uicontrol ('Parent', hObject, 'Units', 'characters', ...
    'Position',[0 vert*height .35*wid .027*height*sizeRatio], ...
    'FontUnits','normalized','FontSize',.9, ...
    'FontWeight','bold', ...
    'Style', 'text', 'String','InspectGUI Options:');
if vert < 0
    set (hff, 'Visible', 'off');
end

% plot InspectGUI options on the GUI
vert = vert - .05*sizeRatio;
InspectOpt = struct('PopulationPlot',pud.PopulationPlot, 'LinkedZoom',pud.LinkedZoom, ...
    'OverPlot',pud.OverPlot, 'SubPlot',pud.subplot);
InspectOpt.flags = {'PopulationPlot', 'LinkedZoom', 'OverPlot'};
[vert, InspectHandles] = optionsGUI (hObject, InspectOpt, sizeRatio, vert);

% create a push button to update data

vert = vert - .05*sizeRatio;
updateCB = 'updatebutton_Callback ';
%argInCB = ['(gcbo, [], get(gcf, 'UserData'), ' num2str(ph, '%.13f') ')'];
%argInCB = '(gcbo, [], get(gcf, ''UserData''), ph)';
argInCB = '(gcbo, [], get(gcf,''UserData''))';
updateCB = [updateCB argInCB];
% h_push = uicontrol('Parent',hObject, 'Units','characters', ...
%                    'Position',[.75*wid vert*height .15*wid .04*height*sizeRatio], ...
%                    'FontUnits','normalized', 'FontSize',.55, ...
%                    'FontWeight','bold', 'Callback',updateCB, ...
%                    'String','Update', 'Style','pushbutton', 'Tag','updatebutton');
h_push = uicontrol('Parent',hObject, 'Units','characters', ...
    'Position',[.75*wid 0.3*vert*height .15*wid .04*height*sizeRatio], ...
    'FontUnits','normalized', 'FontSize',.55, ...
    'FontWeight','bold','Callback',updateCB, ...
    'String','Update', 'Style','pushbutton', 'Tag','updatebutton');
if vert < 0
    set (h_push, 'Visible', 'on');
end

% update the PlotOptions UserData
handlesCollect{1} = [handlesCollect{1} hff InspectHandles{1} h_push];
handlesCollect{2} = {handlesCollect{2}{:}, get(hff, 'Position'), InspectHandles{2}{:}};
lenHC = length(handlesCollect{2});
for ii = (lenHC+1):length(handlesCollect{1})
    handlesCollect{2}{ii} = get(handlesCollect{1}(ii), 'Position');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%put parent handle into figure1.userdata
len = length(handlesCollect);
handlesCollect{len+1} = ph;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(hObject, 'UserData', {});
set(hObject, 'UserData', handlesCollect);


% create a slider at the right side of the PlotOptions window
if vert < 0
    sldrPos = [.95*wid, 0, .05*wid, height];
    sldrMax = 0;
    sldrMin = (vert-.05)*height;
%     h_sldr = uicontrol ('Parent',hObject, 'Style','slider', 'Units','characters', ...
%         'Callback', ['sldrCB (', num2str(hObject, '%.13f'), ')'], ...
%         'Position',sldrPos, 'Min',sldrMin, 'Max',sldrMax, ...
%         'SliderStep',[0.1 0.5], 'Value',0, 'Tag','sldr');
    h_sldr = uicontrol ('Parent',hObject, 'Style','slider', 'Units','characters', ...
        'Callback', 'sldrCB (gcf)', ...
        'Position',sldrPos, 'Min',sldrMin, 'Max',sldrMax, ...
        'SliderStep',[0.1 0.5], 'Value',0, 'Tag','sldr');
end


% Choose default command line output for PlotOptions
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes PlotOptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = PlotOptions_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
set(hObject, 'Visible', 'off');


