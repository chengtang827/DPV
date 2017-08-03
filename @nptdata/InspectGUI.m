function fig = InspectGUI(varargin)
% NPTDATA/InspectGUI Inspect object
%   FIG = InspectGUI(OBJ, VARARGIN) displays a graphical user interface to
%   step through data contained in OBJ.
% 
%   The optional input arguments are:
%      holdaxis - specifies whether to hold the axis limits constant 
%                 across plots.
%      multObjs - specifies that the following cell array contains
%                 all the objects that should be plotted.
%      addObjs - specifies that the following cell array contains
%                additional objects that should be plotted at the
%                same time.
%      ObjectList - specifies that the following cell array contains
%                all the objects, together with the optional input 
%                arguments if any, that should be plotted.
%      optArgs - specifies that the following cell array contains 
%                optional input arguments for the various objects.
%                If this option is not specified, and there is only
%                one object, the remaining arguments are assumed to
%                be optional input arguments.
%      OverPlot - flag specifying that the plots for the different
%                 objects should be plotted on top of one another.
%   Examples:
%   InspectGUI(rf,'addObjs',{rf},'optArgs',{{},{'recovery'}})
%   InspectGUI(bi,'addObjs',{pi,rt})
% 
%   FIG = InspectGUI(OBJ,'holdaxis','addObjs',{OBJ1,OBJ2},'optArgs',{{}})
% 
% 
% This is the machine-generated representation of a Handle Graphics object
% and its children.  Note that handle values may change when these objects
% are re-created. This may cause problems with any callbacks written to
% depend on the value of the handle at the time the object was saved.
% 
% To reopen this object, just type the name of the M-file at the MATLAB
% prompt. The M-file and its associated MAT-file must be on your path.

load InspectGUI
%TODO check different handles, see how they update UI and then PlotOptions
h0 = figure('Units','characters', ...
    'Color',[0.8 0.8 0.8], ...
    'Colormap',mat0, ...
    'Position',[64.8 9.692307692307693 102.4 29.46153846153846], ...
    'Tag','Base');
h1 = uicontrol('Parent',h0, ...
    'Units','characters', ...
    'Callback','InspectCB Previous', ...
    'Position',[22.2 .2946153846153846 13.8 1.61538461538462], ...
    'String','Previous', ...
    'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
    'Units','characters', ...
    'Callback','InspectCB Next', ...
    'Position',[65.8 .2946153846153846 13.8 1.61538461538462], ...
    'String','Next', ...
    'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
    'Units','characters', ...
    'Callback','InspectCB PlotOptions', ...
    'Position',[87.04000000000001 .2946153846153846 13.8 1.61538461538462], ...
    'String','Plot Options', ...
    'Tag','Pushbutton1');
h1 = uicontrol('Parent',h0, ...
    'Units','characters', ...
    'Callback','InspectCB Number', ...
    'Position',[49.8 .2946153846153846 11.8 1.69230769230769], ...
    'Style','edit', ...
    'String', '1', ...
    'Tag','EditText1');
h1 = uicontrol('Parent',h0, ...
    'Units','characters', ...
    'Position',[36.8 .2946153846153846 12.4 1.30769230769231], ...
    'String','Number:', ...
    'Style','text', ...
    'Tag','StaticText1');
h1 = axes('Parent',h0, ...
    'CameraUpVector',[0 1 0], ...
    'CameraUpVectorMode','manual', ...
    'Color',[1 1 1], ...
    'ColorOrder',mat1, ...
    'Units','characters', ...
    'Position',[7.4 4.06569230769231 90.40000000000001 23], ...
    'Tag','Axes1', ...
    'XColor',[0 0 0], ...
    'YColor',[0 0 0], ...
    'ZColor',[0 0 0]);

% set the CloseRequestFn
set(gcf,'CloseRequestFcn','InspectCB Quit');

if nargout > 0, fig = h0; end

% by default, use the first argument as the object. This can be changed
% with the optional argument 'multipleObjs'.
obj{1} = varargin{1};
% parse input argument to see if we need to overide object's HoldAxis property
% first argument is the object so remove it

[varargin,num_args] = removeargs(varargin,1,1);

s =  struct ('HoldAxis', 0, 'multObjs', {''}, 'addObjs', {''}, ...
            'ObjectList', {''}, 'dir', {''}, 'optArgs',{''}, ...
            'OverPlot', 0, 'LinkedZoom', 0, 'PopulationPlot', 0);
s.flags = {'HoldAxis', 'OverPlot', 'LinkedZoom', 'PopulationPlot'};
            
[s, varargin2] = getOptArgs (varargin, s, ...
                               'remove', {'HoldAxis', 'multObjs', 'addObjs', ...
                               'ObjectList', 'Groups', 'optArgs', 'dir', ...
                               'OverPlot', 'LinkedZoom', 'PopulationPlot'});
   

if ~isempty(s.multObjs)
    obj = s.multObjs;
    noptArgs = length(s.optArgs);
    nobj = length(s.multObjs);
    if (noptArgs~=nobj)
        % there should be the same number of optArgs as objects
        % if an object does not have arguments, an empty cell array
        % should still be present. Need empty cell arrays instead
        % of empty numerical arrays created by cell(n,m) in order for
        % the optional arguments to be passed on properly
        for i=(noptArgs+1):nobj
            s.optArgs{i} = {};
        end
    end
elseif ~isempty(s.addObjs)
    obj = {obj{1}, s.addObjs{:}};
    noptArgs = length(s.optArgs);
    nobj = length(s.addObjs) + 1;
    if (noptArgs~=nobj)
        % there should be the same number of optArgs as objects
        % if an object does not have arguments, an empty cell array
        % should still be present. Need empty cell arrays instead
        % of empty numerical arrays created by cell(n,m) in order for
        % the optional arguments to be passed on properly
        for i=(noptArgs+1):nobj
            s.optArgs{i} = {};
        end
    end
elseif ~isempty(s.ObjectList)
    nobj = length(s.ObjectList);
    for i = 1:nobj
        obj{i} = s.ObjectList{i}{1};
        
        if length(s.ObjectList{i}) >1
            s.optArgs{i} = s.ObjectList{i}{2};
        else
            s.optArgs{i} = {};
        end
    end
else
    s.optArgs = {varargin2};
end

s.dir{1} = nptPWD;

% get total number of objects
nobj = length(obj);
% if there are multiple objects, get the directories
if (nobj>1)
    ndir = length(s.dir);
    if (ndir~=nobj)
        % if there are not enough directories, use the first directory,
        % which is the current directory, to fill in the rest
        for i=(ndir+1):nobj
            s.dir{i} = s.dir{1};
        end
    end
end


% pass optional arguments for the object as well so that the get
% function can figure events using the optional arguments that
% the plot function is getting
if s.PopulationPlot
    s.ev = event (1, 1);
else
    s.ev = event(1, get(obj{1},'Number',s.optArgs{1}{:},varargin2{:}));
end
s.HoldAxis = get(obj{1},'HoldAxis');
s.obj = obj; 
s.subplot = [];

set(h0, 'UserData', s);

InspectFn (h0, 1, varargin2{:});