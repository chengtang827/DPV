function varargout = ObjectGUI(varargin)
% OBJECTGUI M-file for ObjectGUI.fig
%      OBJECTGUI, by itself, creates a new OBJECTGUI or raises the existing
%      singleton*.
%
%      H = OBJECTGUI returns the handle to a new OBJECTGUI or the handle to
%      the existing singleton*.
%
%      OBJECTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECTGUI.M with the given input arguments.
%
%      OBJECTGUI('Property','Value',...) creates a new OBJECTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ObjectGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ObjectGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help ObjectGUI

% Last Modified by GUIDE v2.5 07-Mar-2007 21:31:03


% ObjectGUI provides the user the addition and deletion of the directories.
% It also provides the selection of the directory of the objects and object,
% as well as modification of the constructor options of the repective object.
%
% Call ObjectGUI directly WITHOUT any input arguments:
%   Besides the basic functions introduced above, the ObjectGUI provides
%       the selection of 'Process...' and will show the respective 
%       'Process...' options for user to modify.
%   It shows the directory. User can load the current directory by
%       clicking on the pushbutton 'PWD'. User can also change the current
%       direcotry of MATLAB through ObjectGUI.
%   The object is created with the constructor options and 'Process...'
%       options by the selected 'Process...'.
%
% Call ObjectGUI by other functions or GUIs WITH input arguments:
%   Besides the basic functions introduced above, the ObjectGUI provides
%       the modification of the plot options of the respective object.
%   The first input argument is the handle of the calling figure.
%       The second optional input argument is the handle of the object
%       which contains some object names on the ObjectEdit GUI when the
%       ObjectGUI GUI is called for modification of the specified object.
%   When user clicks 'Done' button, the ObjectGUI will return a string of
%       the selected object name, constructor options and plot options.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ObjectGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ObjectGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
               
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end


%push test

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ObjectGUI is made visible.
function ObjectGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ObjectGUI (see VARARGIN)


% save the parent figure handle if the ObjectGUI is a callback
dirInd = [];
objInd = [];

dataDirectory = [prefdir filesep 'dirObjAndDirList'];

try
    load (dataDirectory);
    listDirName = fieldnames(dirObjList);
catch
    dirObjList = {};
    listDirName = {};
end

listObjName = {};
for ii = 1:length(listDirName)
    listObjName{ii} = eval(['dirObjList.' listDirName{ii}]);
end
if ~isempty(varargin)
    handles.parFig = varargin{1};
    if length(varargin) > 1
        % Save the objectGUI handle to objectEdit GUI
        objEditHandles = guidata(varargin{1});
        objEditHandles.modify = hObject;
        guidata(varargin{1}, objEditHandles);
    else
        % Save the objectGUI handle to objectEdit GUI
        objEditHandles = guidata(varargin{1});
        objEditHandles.add = hObject;
        guidata(varargin{1}, objEditHandles);      
    end
        
    
    if nargin > 4
        % find out the selected object in the directory
        handles.editObjInd = get(varargin{2}, 'Value');
        if isempty(handles.editObjInd)
            display ('Please select an object.');
        end
        objNameStr = get(varargin{2}, 'String');
        for ii = 1:length(listDirName)
            for jj = 1:length(listObjName{ii})
                if strcmp(listObjName{ii}{jj}, objNameStr{handles.editObjInd})
                    dirInd = ii;
                    objInd = jj;
                    break;
                end
            end
        end
    end
else
    set (gcf, 'Position', [103.8 15.307692307692308 140.0+2 46.15384615384615]);
    hPanelPlot = findobj(gcf, 'Tag', 'uipanelPlotOption');
    set(hPanelPlot, 'Visible', 'off');
    % create a popupmenu for ProcessDays, ProcessDay......
    processStr = {'Process...','---------------','Dirs','---------------','Level'};
    hProcess = uicontrol('Parent',gcf, 'Style','popupmenu', 'Tag','Process', ...
                      'FontUnits','normalized', 'FontSize',.5, 'Units','characters', ...
                      'Position',[2.8 42.7 22 2.307692307692308], ...
                      'String',processStr, 'Enable','off', 'Callback','ObjectCB');
                  
    hStDirLable = uicontrol('Parent',gcf, 'Style','text', 'Units','characters', ...
                       'FontUnits','normalized', 'FontSize',.5, 'FontWeight','bold', ...
                       'Position',[32-4 42.3 28 2.307692307692308], 'HorizontalAlignment','center', ...
                       'String','Starting Directory:', 'HorizontalAlignment','left');
                   
    hDirHis = uicontrol ('Parent',gcf, 'Style','popupmenu', 'Tag','dirHistory', ...
                         'FontUnits','normalized', 'FontSize',.5, 'Units','characters', ...
                         'Position',[60.5-8 42.7 60-10 2.307692307692308], ...
                         'String',pwd, 'Callback','ObjectCB', ...
                         'HorizontalAlignment','center');
    dirString = pwd;
    try
        load (dataDirectory);
        
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
        
    catch
        dirList = {dirString};
        
    end
    set (hDirHis, 'String', dirList);
    save (dataDirectory, 'dirList', 'dirObjList');
    clear dirList dirObjList;

    hDirGet = uicontrol ('Parent',gcf, 'Style','pushbutton', 'Tag','dirGet', ...
        'FontUnits','normalized', 'FontSize',.5, 'Units','characters', ...
        'Position',[122-19 43 6 2.307692307692308], 'HorizontalAlignment','center', ...
        'String','...', 'Callback','ObjectCB');

%     hPwdGet = uicontrol ('Parent',gcf, 'Style','pushbutton', 'Units','characters', ...
%         'FontUnits','normalized', 'FontSize',.5, ...
%         'Max',2, 'Min',1, 'Position',[129 43 8 2.307692307692308], ...
%         'String','pwd', 'Tag','pwdGet', 'Callback','ObjectCB', ...
%         'HorizontalAlignment','center');
    hPwdGet = uicontrol ('Parent',gcf, 'Style','pushbutton', 'Units','characters', ...
        'FontUnits','normalized', 'FontSize',.5, ...
        'Max',2, 'Min',1, 'Position',[129-20 43 8+24 2.307692307692308], ...
        'String','Add Current Directory', 'Tag','pwdGet', 'Callback','ObjectCB', ...
        'HorizontalAlignment','center');

end
                  
                     
% create listbox of Directory
hDir = uicontrol ('Parent',gcf, 'Units','characters',  ...
                  'Position',[2.2 5.6923076923076925 23.0 32.69230769230769], ...
                  'Style','listbox', 'Tag','Directory', ...
                  'HorizontalAlignment','left', 'FontSize',11, ...
                  'String',listDirName, 'Callback','ObjectCB', ...
                  'Min',0, 'Max',2, 'Value',dirInd);
% add hDir to handles
handles.Directory = hDir;

% create listbox of Object
hObj = uicontrol ('Parent',gcf, 'Units','characters',  ...
                  'Position',[25.0 5.6923076923076925 25.0 32.69230769230769], ...
                  'Style','listbox', 'Tag','Object', ...
                  'HorizontalAlignment','left', 'FontSize',11, ...
                  'Callback','ObjectCB', ...
                  'Min',0, 'Max',2, 'Value',objInd);
% add hObj to handles
handles.Object = hObj;
if ~isempty(objInd)
    guidata(hObject, handles);
    set (hObj, 'String', listObjName{dirInd});
    objOptStrList = get(varargin{1}, 'UserData');
    objOptStrInd = get(varargin{2}, 'Value');
    objOptStr = objOptStrList{objOptStrInd};
    if strcmp(objOptStr, 'None')
        objOptStr = '';
    end
    ObjectCB ('Object', hObject, objOptStr);
    handles = guidata(hObject);
end

% create two checkboxes for user to add and delete a directory
hDirAdd = uicontrol ('Parent',gcf, 'Units','characters', 'Style','pushbutton', ...
                     'FontUnits','normalized', 'FontSize',.9, 'FontWeight','bold', ...
                     'Position',[2.8 3.4615384615384617 6.0 2.307692307692308], ...
                     'Tag','dirAdd', 'String','+', 'Callback','ObjectCB');
                 
hDirDelete = uicontrol ('Parent',gcf, 'Units','characters', 'Style','pushbutton', ...
                        'FontUnits','normalized', 'FontSize',.9, 'FontWeight','bold', ...
                        'Position',[10.5 3.4615384615384617 6.0 2.307692307692308], ...
                        'Tag','dirDelete', 'String','-', 'Callback','ObjectCB');
                 

% create pushbutton of Done
if isfield (handles, 'parFig')
    donePos = [204 1.6923076923076923 16.0 2];
else
    hName = uicontrol ('Parent',gcf, 'Units','characters', ...
                       'Position',[68 1.66 10 1.65], 'HorizontalAlignment','center', ...
                       'Style','text', 'String','Name:', ...
                       'FontUnits','normalized', 'FontSize',.72, 'FontWeight','bold');
    hNameEdit = uicontrol ('Parent',gcf, 'Units','characters', ...
                           'Position',[79 1.75 25 1.65], 'Style','edit', ...
                           'Tag','Name', 'HorizontalAlignment','center', ...
                           'FontUnits','normalized', 'Fontsize',.72);
        
    donePos = [114 1.6923076923076923 16.0 2];
end
hDone = uicontrol ('Parent', gcf, 'Units','characters', 'Position', donePos, ...
                   'Style','pushbutton', 'Tag','Done', 'String','Done', ...
                   'FontUnits','normalized', 'FontSize',.55, 'FontWeight','bold', ...
                   'Callback','ObjectCB');

% add hDone to handles
handles.Done = hDone;


% Choose default command line output for ObjectGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% set the renderer property of gcf
set(gcf, 'Renderer', 'zbuffer');

% UIWAIT makes ObjectGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ObjectGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


