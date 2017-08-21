function [robj,data] = ProcessDay(obj,varargin)
%NPTDATA/ProcessDay	Process a day's data.
%   ROBJ = ProcessDay(OBJ) checks the local directory for data to 
%   process and returns the processed object in ROBJ. It does the
%   following:
%      a) Checks the local directory for the presence of files named
%   either skip.txt or processedday{classname}.txt. If either are 
%   present, the function will exit, unless the argument 'redo' is 
%   present.
%      b) Changes directory to each site directory and calls
%   ProcessSite(OBJ).
%      c) Creates processedday{classname}.txt in the local directory.
%
%   ProcessDay(OBJ,ARG1,ARG2,...) takes the following optional arguments,
%   which are also passed to ProcessSite:
%      'Reprocess'   If this is the only argument, the function 
%                    performs all operations even if processedday.txt 
%                    is present.
%   The following optional arguments are only used by this function:
%      'Sites'	     Processes selected sites instead of all 
%                    sites found in the local directory. This 
%                    argument must be followed by a cell array 
%                    containing a list of site names, 
%                    e.g. {'08','09'}.
%      'SkipSites'   Skips the directories specified in a cell array.
%                    This option cannot be used together with the Sites
%                    option.
%      'nptDayCmd'   Performs the following command for each day 
%                    directory.
%      'NoSites'     Flag used to indicate old behavior (calls
%                    ProcessSession instead of ProcessSites).
%      'DayObject'   Flag that indicates that the object should be
%                    instantiated at this level.
%
%	Dependencies: removeargs, nptDir, @nptdata/ProcessSite,
%      @nptdata/checkMarkers, @nptdata/createProcessedMarker.

% for temporary backward compatability, we parse both Sites/SkipSites and
% Sessions/SkipSessions optional input argument
Args = struct('RedoValue',0,'nptDayCmd','','Sites','','SkipSites','',...
	'NoSites',0,'Sessions','','SkipSessions','','DayObject',0,'DataInit',[], ...
	'DataPlusCmd','');
[Args,varargin2] = getOptArgs(varargin,Args, ...
	'shortcuts',{'Reprocess',{'RedoValue',1}},...
	'flags',{'NoSites','DayObject'});
% if we are  using NoSites then we should copy Sessions to Sites and
% SkipSessions to SkipSites
if(Args.NoSites)
    if(~isempty(Args.Sessions))
        Args.Sites = Args.Sessions;
    end
    if(~isempty(Args.SkipSessions))
        Args.SkipSites = Args.SkipSessions;
    end
end

% add eyecal directory to SkipSites if it is not already there
if( isempty(Args.SkipSites) )
    Args.SkipSites = {'eyecal'};
end

robj = obj;
data = Args.DataInit;

if (~checkMarkers(obj,Args.RedoValue,'day'))
	% check if object should be instantiated at the Day level
	if(isempty(Args.DayObject))
		% DayObject argument was not specified so check the object properties
		if(strcmp(get(obj,'ObjectLevel'),'Day'))
			Args.DayObject = 1;
		end
	end
	if(Args.DayObject)
		robj = feval(class(obj),'auto',varargin2{:});
	elseif(isempty(Args.nptDayCmd))
		% get sites
		sites = nptDir;
		for i = 1:size(sites,1);
			% check to make sure it is of the right format
			if(sites(i).isdir)
				% get name of directory
				site_num = sites(i).name;
				% only continue if Sites is empty or dname matches Sites
				% and SkipSites is empty or dname does not match SkipSites
				% use shortcut form of or operator so we don't have to
				% check if Sites or SkipSites is empty before doing the
				% skipcmpi operation
				if( (isempty(Args.Sites) || (sum(strcmpi(site_num,Args.Sites))>0)) ...
				&& (isempty(Args.SkipSites) || sum(strcmpi(site_num,Args.SkipSites))==0) )
					fprintf(['\tProcessing Site ' site_num '\n']);
                    cd (site_num)
					if(Args.NoSites)
						% old style usage calls ProcessSession
						[p,pdata] = ProcessSession(eval(class(obj)),varargin2{:});
					else
						% use eval(class(obj)) to create empty object so the 
						% correct ProcessSite will be called.
						[p,pdata] = ProcessSite(eval(class(obj)),varargin2{:});
					end
					robj = plus(robj,p,varargin2{:});
					if(~isempty(Args.DataPlusCmd))
						eval(Args.DataPlusCmd);
					end
					cd ..
				end
			end
		end    
	else
		eval(Args.nptDayCmd);
	end    
    % create marker if necessary
    createProcessedMarker(obj,'day');   
else
    fprintf('\t\tSkipped\n');
end % if marker file exists
