function [robj,data] = ProcessGroup(obj,varargin)
%NPTDATA/ProcessGroup	Process group data.
%   ROBJ = ProcessGroup(OBJ) checks the local directory for data to 
%   process and returns the processed object in ROBJ.
%   It does the following:
%      a) Checks the local directory for the presence of files named
%   either skip.txt or processedgroup{classname}.txt. If either are 
%   present, the function will exit, unless the argument 'redo' is 
%   present.
%      b) Changes directory to each cell directory and calls 
%   ProcessCell(OBJ).
%      c) Creates processedgroup{classname}.txt.
%
%   ProcessGroup(OBJ,ARG1,ARG2,...) takes the following optional 
%   arguments, which are also passed to ProcessTrial:
%      'Reprocess'    If this is the only argument, the function 
%                     performs all operations even if 
%                     processedgroup.txt is present.
%      'Cells'        Processes the specified cells instead of all
%                     cells found in the group directory.
%      'SkipCells'    Skips the directories specified in a cell array.
%                     This option cannot be used together with the 
%                     Cells option.
%      'nptGroupCmd'  Performs the following command for each
%                     group. Be sure to set the output variable
%                     robj if the nptdata object created is to be 
%                     added to other objects.
%      'GroupObject'  Flag that indicates that the object should be
%                     instantiated at this level.
%      'UnitType'     Processes the cells with the last character of the
%                     directory name match the string (ie. 'm' for
%                     multiunit clusters and 's' for single unit).
%      'CellDirName'  Specifies string pattern to use to search for 
%                     cluster directories (default: '').
%
%	Dependencies: @nptdata/checkMarkers, @nptdata/createProcessedMarker, 
%      @nptdata/ProcessTrial. 

Args =  struct('RedoValue',0,'nptGroupCmd','','Cells','','SkipCells','', ...
	'GroupObject',0,'UnitType','','CellDirName','','DataInit',[], ...
	'DataPlusCmd','');
Args.flags = {'GroupObject'};
[Args,varargin2] = getOptArgs(varargin,Args, ...
    'shortcuts',{'Reprocess',{'RedoValue',1}}, ...
	'remove',{'GroupObject'});

% Cells and SkipCells can be specified using full paths or just the
% names for this directory so we need to add the full path for the latter
% get current directory
cwd = pwd;
% get the pathname for the Cells and SkipCells argument
if(~isempty(Args.Cells))
	% check if Cells were specified with full pathnames
	% we are going to assume that either all the directories are
	% full-paths or relative-paths so we are going to just check the
	% first entry
	[p,n] = nptFileParts(Args.Cells{1});
	if(isempty(p))
		% directories were specified with relative paths so we are going
		% to add the current directory to it
		for celli = 1:length(Args.Cells)
			Args.Cells{celli} = [cwd filesep Args.Cells{celli}];
		end
	end
end
if(~isempty(Args.SkipCells))
	% check if SkipCells were specified with full pathnames
	% we are going to assume that either all the directories are
	% full-paths or relative-paths so we are going to just check the
	% first entry
	[p,n] = nptFileParts(Args.SkipCells{1});
	if(isempty(p))
		% directories were specified with relative paths so we are going
		% to add the current directory to it
		for celli = 1:length(Args.SkipCells)
			Args.SkipCells{celli} = [cwd filesep Args.SkipCells{celli}];
		end
	end
end

% assign input object to output object so that we can just add new object
% to input object. This will also ensure that we always return an object
robj = obj;
data = Args.DataInit;

% check markers to see if we need to process this group

if (~checkMarkers(obj,Args.RedoValue,'group'))
	% check if object should be instantiated at the Group level
	if(isempty(Args.GroupObject))
		% GroupObject argument was not specified so check the object properties
		if(strcmp(get(obj,'ObjectLevel'),'Group'))
			Args.GroupObject = 1;
		end
	end
	if(Args.GroupObject)
		robj = feval(class(obj),'auto',varargin2{:});
	elseif isempty(Args.nptGroupCmd)
        if(isempty(Args.CellDirName))
			% loop over cells in directory
			scells = nptDir;
        else
            scells = nptDir(Args.CellDirName);
        end
		for i = 1:size(scells,1);
			% check to make sure it is a directory
            if(scells(i).isdir)
                % get name of directory
                scell_num = scells(i).name;
                % add current directory to it
                scell_fullpath = [cwd filesep scell_num];
                % only continue if Cells is empty or dname matches Cells
                % and SkipCells is empty or dname does not match SkipCells
                % use shortcut form of or operator so we don't have to
                % check if Cells or SkipCells is empty before doing the
                % strcmpi operation
                if( (isempty(Args.Cells) || (sum(strcmpi(scell_fullpath,Args.Cells))>0)) ...
                        && (isempty(Args.SkipCells) || sum(strcmpi(scell_fullpath,Args.SkipCells))==0) )
                    if (isempty(Args.UnitType) || (sum(strcmpi(scell_num(end),Args.UnitType))>0))
                        fprintf(['\t\t\t\tProcessing Cell ' scell_num '\n']);
                        cd(scell_num)
                        [p,pdata] = ProcessCell(eval(class(obj)),varargin2{:});
                        robj = plus(robj,p,varargin2{:});
						if(~isempty(Args.DataPlusCmd))
							eval(Args.DataPlusCmd);
						end
                        cd ..
                    end
                end
            end
		end
	else
		eval(Args.nptGroupCmd);
	end
	% create marker if necessary
	createProcessedMarker(obj,'group');   
end % if marker file exists
