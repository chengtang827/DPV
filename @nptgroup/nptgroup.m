function [obj, varargout] = nptgroup(varargin)
%@nptgroup Constructor function for nptgroup class
%   OBJ = nptgroup(varargin) attempts to create a nptgroup object by
%   checking in the current directory if there are any directories named
%   'cluster*' (this can be changed by using the 'CellName' optional input 
%   argument). If none are found, an empty object is returned.
%   CellList can be a dirlist as returned from nptDir of the cluster
%   directories you want.

Args = struct('RedoLevels',0,'SaveLevels',0,'Auto',0,'NoSingles',0, ...
	'CellName','','CellsList',[],'CellDirs',{''}, ...
	'CellsFile','','GroupDirs',{''},'GroupsFile','', ...
    'GetCellDirs',0, 'ArgsOnly',0,'TempFlag',0);
Args.flags = {'Auto','NoSingles','GetCellDirs','ArgsOnly','TempFlag'};
[Args,varargin2] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'nptgroup';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'ng';

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    varargout{1} = {'Args',Args};
    obj = createEmptyObject(Args);
    return;
end

if(nargin==0)
	% create empty object
	obj = createEmptyObject(Args);
elseif( (nargin==1) & isa(varargin{1},Args.classname))
	obj = varargin{1};
else
	% create object using arguments
	if(Args.Auto)
		% check for saved object
		if(~isempty(nptDir(Args.matname,'CaseInsensitive')) ...
			& (Args.RedoLevels==0))
			fprintf('Loading saved %s object...\n',Args.classname);
			l = load(Args.matname);
			obj = eval(['l.' Args.matvarname]);
		else
			% no saved object so we will try to create one
			% pass varargin in case createObject needs to instantiate
			% other objects that take optional input arguments
			obj = createObject(Args,varargin2{:});
		end
	end
end

function obj = createObject(Args,varargin)

% get current directory name
cwd = pwd;

if(~isempty(Args.GroupsFile))
	% read GroupDirs from file. If GroupDirs is specified as well, then it is
	% overwritten
	Args.GroupDirs = textread(Args.GroupsFile,'%s');
end

% check if a list of specified directories was passed in
if(~isempty(Args.GroupDirs))
	% loop over GroupDirs and create appropriate data structure
	% get GroupDirs
	gd = Args.GroupDirs;
	gdl = length(Args.GroupDirs);	
	% initialize data strucutre
	data.numSets = 0;
	data.setNames = {};
	data.cellNames = {};
	data.numCells = 0;
	data.numCellsIndex = 0;
	for idx = 1:gdl
		% change to directory
		cd(gd{idx})
		% generate ClusterDirs using current directory
		% cellnames = getDataOrder('GetDirs');
		cellnames = {pwd};
		numcells = size(cellnames,2);
		% check to see if the NoSingles argument was specified
		if( (numcells>0 && Args.NoSingles==0) || (numcells>1 && Args.NoSingles==1) )
			% this is a valid object
			data.numSets = data.numSets + 1;
			data.setNames = {data.setNames{:} gd{idx}};
			data.cellNames = {data.cellNames{:} cellnames{:}};
			data.numCells = data.numCells + numcells;
			% set index to keep track of which cells go with which set
			data.numCellsIndex = [data.numCellsIndex; ...
                    data.numCellsIndex(end)+numcells];
		end
		% change back to originial directory in case the directory list that
		% was passed in was relative to original directory
		cd(cwd)
	end
	% check to see if there were any valid directories
	if(data.numSets>0)
		% create nptdata using list in setNames
		n = nptdata('SessionDirs',data.setNames);
		d.data = data;
		obj = class(d,Args.classname,n);
		if(Args.SaveLevels)
			fprintf('Saving %s object...\n',Args.classname);
			% cp = obj;
			eval([Args.matvarname ' = obj;']);
			% save nptgroup ng
			eval(['save ' Args.matname ' ' Args.matvarname]);
		end
	else
		% create empty object if there were no valid directories
		obj = createEmptyObject(Args);
	end
else % if(isempty(Args.GroupDirs))
	% figure out how many cluster directories there are
	if( ~isempty(Args.CellsList) || ~isempty(Args.CellName) )
		if(~isempty(Args.CellsList))
			glist = Args.CellsList;
		else
			glist = dir(Args.CellName);
		end
		% get number of entries
		gnum = size(glist,1);
		cellnames = {};
		numcells = 0;
		for i = 1:gnum
			% make sure each entry is a directory
			if(glist(i).isdir)
				cellnames = {cellnames{:} glist(i).name};
				numcells = numcells + 1;
			end
		end
	elseif(~isempty(Args.CellDirs))
		cellnames = Args.CellDirs;
		numcells = size(cellnames,2);
    elseif(Args.GetCellDirs)
        cellnames = getDataOrder('GetDirs');
        numcells = size(cellnames,2);
    elseif(~isempty(Args.CellsFile))
   		cellnames = textread(Args.CellsFile,'%s');
        numcells = length(cellnames);
    else
        if(Args.TempFlag==0)
            ndg = ProcessLevel(nptdata,varargin{:});
        else
            ndg = ProcessGroup(nptdata,varargin{:});
        end
		cellnames = ndg.SessionDirs;
		numcells = size(cellnames,2);
		% glist = nptDir([Args.CellName 's']);
		% glist = [glist ; nptDir([Args.CellName 'm'])];
	end
	
	% check if there were any valid directories found
	if( (numcells>0 && Args.NoSingles==0) || (numcells>1 && Args.NoSingles==1) )
		% this is a valid object
		data.numSets = 1;
		data.setNames{1} = cwd;
		data.cellNames = cellnames;
		data.numCells = numcells;
		% set index to keep track of which cells go with which set
		data.numCellsIndex = [0; numcells];
		% create nptdata
		n = nptdata(data.numSets,0,cwd);
		d.data = data;
		obj = class(d,Args.classname,n);
		if(Args.SaveLevels)
			fprintf('Saving %s object...\n',Args.classname);
			% cp = obj;
			eval([Args.matvarname ' = obj;']);
			% save nptgroup ng
			eval(['save ' Args.matname ' ' Args.matvarname]);
		end
	else
		% create empty object
		obj = createEmptyObject(Args);
	end
end % if(isempty(Args.GroupDirs))

function obj = createEmptyObject(Args)

data.numSets = 0;
data.setNames = '';
data.cellNames = '';
data.numCells = [];
data.numCellsIndex = [];
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
