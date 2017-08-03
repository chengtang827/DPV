function [obj, varargout] = checkFiles(varargin)
%@checkFiles Constructor function for CHECKFILES class

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,'Option','');
Args.flags = {'Auto','ArgsOnly','RedoLevels','SaveLevels'};
% The arguments which can be neglected during arguments checking
Args.UnimportantArgs = {'RedoLevels','SaveLevels'};                            

[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'checkFiles';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'cf';

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
saveObject(obj,'ArgsC',Args);


function obj = createObject(Args,varargin)

nfile = 0;
nmat = 0;
nbin = 0;
ntxt = 0;

list = nptDir;
if(~isempty(list))
    for i = 1:size(list,1)
        if(~list(i).isdir)
            nfile = nfile + 1;
            format = list(i).name;
            switch format(end-3:end)
                case '.mat'
                    if(isempty(Args.Option) || strcmp(Args.Option,'mat'))
                        nmat = nmat + 1;
                    end
                case '.bin'
                    if(isempty(Args.Option) || strcmp(Args.Option,'bin'))
                        nbin = nbin + 1;
                    end
                case '.txt'
                    if(isempty(Args.Option) || strcmp(Args.Option,'txt'))
                        ntxt = ntxt + 1;
                    end
            end
        end
    end
    data.nfile = nfile;
    data.nmat = nmat; 
    data.nbin = nbin;
    data.ntxt = ntxt;
    data.fdir = {pwd};
    data.Args = Args;
    n = nptdata(1,0,pwd);
    d.data = data;
    obj = class(d,Args.classname,n);
else
    obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

data.nfile = 0;
data.nmat = 0;
data.nbin = 0;
data.ntxt = 0;
data.fdir = {''};
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
