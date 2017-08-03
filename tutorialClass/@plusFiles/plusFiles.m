function [obj, varargout] = plusFiles(varargin)
%@plusFiles Constructor function for PLUSFILES class

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,...
    'Dirs','','Option','');
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.UnimportantArgs = {'RedoLevels','SaveLevels','Dirs'};                            

[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'plusFiles';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'pf';

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

if(isempty(Args.Dirs))
    % try finding ClusterDirs using current directory
    Args.Dirs = getDataOrder('GetDirs');
end
listlength = length(Args.Dirs);
cwd = pwd;
nfile = zeros(1,listlength);
nmat = zeros(1,listlength);
nbin = zeros(1,listlength);
ntxt = zeros(1,listlength);

for i = 1:listlength
    cd(Args.Dirs{i})
    list = nptDir;
    if(~isempty(list))
        for k = 1:size(list,1)
            if(~list(k).isdir)
                nfile(1,i) = nfile(1,i) + 1;
                format = list(k).name;
                switch format(end-3:end)
                    case '.mat'
                        if(isempty(Args.Option) || strcmp(Args.Option,'mat'))
                            nmat(1,i) = nmat(1,i) + 1;
                        end
                    case '.bin'
                        if(isempty(Args.Option) || strcmp(Args.Option,'bin'))
                            nbin(1,i) = nbin(1,i) + 1;
                        end
                    case '.txt'
                        if(isempty(Args.Option) || strcmp(Args.Option,'txt'))
                            ntxt(1,i) = ntxt(1,i) + 1;
                        end
                end
            end
        end
    else
        nfile(1,i) = 0;
        nmat(1,i) = 0;
        nbin(1,i) = 0;
        ntxt(1,i) = 0;
    end
end
sumnfile = sum(nfile,2);
sumnmat = sum(nmat,2);
sumnbin = sum(nbin,2);
sumntxt = sum(ntxt,2);
cd(cwd)

data.nfile = sumnfile;
data.nmat = sumnmat;
data.nbin = sumnbin;
data.ntxt = sumntxt;
data.fdir = {cwd};
data.Args = Args;
n = nptdata(1,0,pwd);
d.data = data;
obj = class(d,Args.classname,n);

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
