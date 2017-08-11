function [obj, varargout] = psth(varargin)
%@psth Constructor function for PSTH class
%   OBJ = psth(varargin)
%
%   OBJ = psth('auto') attempts to create a poststimulus time histogram
%   object
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on psth %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = psth('save','redo')
%
%dependencies:

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0);
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.UnimportantArgs = {'RedoLevels','SaveLevels'};

[Args,modvarargin] = getOptArgs(varargin,Args, ...
    'subtract',{'RedoLevels','SaveLevels'}, ...
    'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
    'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'psth';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'ps';

% To decide the method to create or load the object
command = checkObjCreate('ArgsC',Args,'narginC',nargin,'firstVarargin',varargin);

if(strcmp(command,'createEmptyObjArgs'))
    varargout{1} = {'Args',Args};
    obj = createEmptyObject(Args);
elseif(strcmp(command,'createEmptyObj'))
    obj = createEmptyObject(Args);
elseif(strcmp(command,'passedObj'))
    obj = varargin{1};
elseif(strcmp(command,'loadObj'))
    l = load(Args.matname);
    obj = eval(['l.' Args.matvarname]);
elseif(strcmp(command,'createObj'))
    % IMPORTANT NOTICE!!!
    % If there is additional requirements for creating the object, add
    % whatever needed here
    obj = createObject(Args,varargin{:});
end

function obj = createObject(Args,varargin)

% example object
dlist = nptDir('session*');
% get entries in directory
dnum = size(dlist,1);

% check if the right conditions were met to create object
ps = psth;
if(dnum>0)
    for i = 1:length(dlist)
        [spikeCount, stimLoc, theStim]= ProcessSession(ps,dlist(i).name,varargin);
        data.session(i).spikeCount = spikeCount;
        data.session(i).stimLoc = stimLoc;
        data.session(i).theStim = theStim;
    end
    
    % this is a valid object
    % these are fields that are useful for most objects
    data.numSets = dnum;
    data.Args = Args;
    
    % these are object specific fields
    data.dlist = dlist;
    % set index to keep track of which data goes with which directory
    data.setIndex = dnum;
    
    % create nptdata so we can inherit from it
    
    data.Args = Args;
    n = nptdata(data.numSets,0,pwd);
    d.data = data;
    obj = class(d,Args.classname,n);
       
    saveObject(obj,'ArgsC',Args);
else
    % create empty object
    obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

% useful fields for most objects
data.numSets = 0;
data.setNames = '';

% these are object specific fields
data.dlist = [];
data.setIndex = [];

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);

