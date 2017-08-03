function varargout = objectEdit(varargin)
% OBJECTEDIT M-file for objectEdit.fig
%      OBJECTEDIT, by itself, creates a new OBJECTEDIT or raises the existing
%      singleton*.
%
%      H = OBJECTEDIT returns the handle to a new OBJECTEDIT or the handle to
%      the existing singleton*.
%
%      OBJECTEDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECTEDIT.M with the given input arguments.
%
%      OBJECTEDIT('Property','Value',...) creates a new OBJECTEDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before objectEdit_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to objectEdit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help objectEdit

% Last Modified by GUIDE v2.5 30-Jun-2006 16:27:06


% This function should not be accessed by user.
%
% This function is called by other functions or GUIs, e.g. PlotOptions GUI.
% 
% 

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @objectEdit_OpeningFcn, ...
                   'gui_OutputFcn',  @objectEdit_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before objectEdit is made visible.
function objectEdit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to objectEdit (see VARARGIN)

% save the callback figure handle
handles.parFig = varargin{1};

% get the objects from 'Objects' in PlotOptions
hEditObject = varargin{2};
objString = get(hEditObject, 'String');
if ~isempty(objString)
    objects = eval(objString);
    if strcmp(get(hEditObject, 'Tag'), 'editObject')
        objects = {objects};
    end
else
    objects = {};
end

numObj = length(objects);
objNameList = {};
for ii = 1:numObj
    objNameList = {objNameList{:}, objects{ii}{1}};
end
    
objOptStrList = {};
for ii = 1:numObj
    cellNum = length(objects{ii});

    if cellNum > 2
        objString = [cell2str(objects{ii}{2}) ', ' cell2str(objects{ii}{3})];
    elseif cellNum > 1
        objString = cell2str(objects{ii}{2});
    else
        objString = 'None';
    end
   
    objOptStrList{ii} = objString;
end

set(gcf, 'UserData', objOptStrList);

hObjOpt = uicontrol('Parent',gcf, 'Style','edit', 'Units','characters', ...
                    'Position',[29.8 3.76923076923077 60.0 23.076923076923077], ...
                    'FontUnits','normalized', 'FontSize',.055, ...
                    'Tag','objOpt', ...
                    'min',0,'max',2,'enable','inactive', ...
                    'HorizontalAlignment','left');

hObjName = uicontrol('Parent',gcf, 'Style','listbox', 'Units','characters', ...
                     'Position',[1.8 3.76923076923077 28.0 23.076923076923077],...
                     'FontUnits','normalized', 'FontSize',.05, ...
                     'String',objNameList, 'Tag','objName', ...
                     'min',0, 'max',2, 'Value',[], ...
                     'Callback',['ObjectEditCB(' num2str(hObjOpt,'%.13f') ')']);
                 
hModify = uicontrol ('Parent',gcf, 'Style','pushbutton', 'Units','characters', ...
                     'Position',[11.8 0.6923076923076923 16.0 2.307692307692308], ...
                     'FontUnits','normalized', 'FontSize',.6, ...
                     'String','Modify', 'Tag','Modify', ...
                     'Callback',['ObjectEditCB(' num2str(hObject,'%.13f') ',' ...
                     num2str(hObjName,'%.13f') ')']);
                 
hDelete = uicontrol ('Parent',gcf, 'Style','pushbutton', 'Units','characters', ...
                     'Position',[31.8 0.6923076923076923 16.0 2.307692307692308], ...
                     'FontUnits','normalized', 'FontSize',.6, ...
                     'String','Delete', 'Tag','Delete', ...
                     'Callback',['ObjectEditCB(' num2str(hObjName,'%.13f') ',' ...
                     num2str(hObjOpt,'%.13f') ')']);
                 
hAdd = uicontrol ('Parent',gcf, 'Style','pushbutton', 'Units','characters', ...
                  'Position',[51.8 0.6923076923076923 16.0 2.307692307692308], ...
                  'FontUnits','normalized', 'FontSize',.6, ...
                  'String','Add', 'Tag','Add', ...
                  'Callback',['ObjectEditCB(' num2str(hObject,'%.13f') ')']);
                 
hDone = uicontrol ('Parent',gcf, 'Style','pushbutton', 'Units','characters', ...
                   'Position',[71.8 0.6923076923076923 16.0 2.307692307692308], ...
                   'FontUnits','normalized', 'FontSize',.6, ...
                   'String','Done', 'Tag','editDone', ...
                   'Callback',['ObjectEditCB(', num2str(varargin{1}, '%.13f'), ',', ...
                               num2str(hObject, '%.13f'), ',', num2str(varargin{2}, '%.13f'), ')']);
                                 

                             
% Choose default command line output for objectEdit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Save the objectEdit GUI handle to PlotOptions GUI
plotOptHandles = guidata(varargin{1});
plotOptHandles.objEdit = hObject;
guidata(varargin{1}, plotOptHandles);

% UIWAIT makes objectEdit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = objectEdit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
