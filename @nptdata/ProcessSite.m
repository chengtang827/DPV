function [robj,data] = ProcessSite(obj,varargin)
%NPTDATA/ProcessSite	Process a site's data.
%   ROBJ = ProcessSite(OBJ) checks the local directory for data to 
%   process and returns the processed object in ROBJ. It does the
%   following:
%      a) Checks the local directory for the presence of files named
%   either skip.txt or processedsite{classname}.txt. If either are 
%   present, the function will exit, unless the argument 'redo' is 
%   present.
%      b) Changes directory to each site directory and calls
%   ProcessSession(OBJ).
%      c) Creates processedsite{classname}.txt in the local directory.
%
%   ProcessSite(OBJ,ARG1,ARG2,...) takes the following optional 
%   arguments, which are also passed to ProcessSession:
%      'Reprocess'    If this is the only argument, the function 
%                     performs all operations even if processedsite.txt 
%                     is present.
%   The following optional arguments are only used by this function:
%      'Sessions'     Processes specified directories instead of all 
%                     directories found in the local directory. This 
%                     argument must be followed by a cell array 
%                     containing a list of directory names, 
%                     e.g. {'08','09'}.
%      'SkipSessions' Skips the directories specified in a cell array.
%                     This option cannot be used together with the 
%                     Sessions option.
%      'nptSiteCmd'   Performs the following command for each site 
%                     directory.
%      'SiteObject'   Flag that indicates that the object should be
%                     instantiated at this level.
%
%	Dependencies: removeargs, nptDir, @nptdata/ProcessSession,
%      @nptdata/checkMarkers, @nptdata/createProcessedMarker.

Args = struct('RedoValue',0,'nptSiteCmd','','Sessions','', ...
	'SkipSessions','','SiteObject',0,'DataInit',[],'DataPlusCmd','');
Args = getOptArgs(varargin,Args,'shortcuts',{'Reprocess',{'RedoValue',1}}, ...
	'flags',{'SiteObject'});

robj = obj;
data = Args.DataInit;

if (~checkMarkers(obj,Args.RedoValue,'site'))
	% check if object should be instantiated at the site level
	if(isempty(Args.SiteObject))
		% SiteObject argument was not specified so check the object properties
		if(strcmp(get(obj,'ObjectLevel'),'Site'))
			Args.SiteObject = 1;
		end
	end
	if(Args.SiteObject)
		robj = feval(class(obj),'auto',varargin{:});
	elseif(isempty(Args.nptSiteCmd))
		% get sessions
		sessions = nptDir;
		for i = 1:size(sessions,1);
			% check to make sure it is of the right format
			if sessions(i).isdir
				% get name of directory
				ses_num = sessions(i).name;
				% only continue if Sessions is empty or dname matches Sessions
				% and SkipSessions is empty or dname does not match SkipSessions
				% use shortcut form of or operator so we don't have to
				% check if Sessions or SkipSessions is empty before doing the
				% skipcmpi operation
				if( (isempty(Args.Sessions) || (sum(strcmpi(ses_num,Args.Sessions))>0)) ...
				&& (isempty(Args.SkipSessions) || sum(strcmpi(ses_num,Args.SkipSessions))==0) )
					fprintf(['\t\tProcessing Session ' ses_num '\n']);
					cd (ses_num)
					% use eval(class(obj)) to create empty object so the
					% correct ProcessSession will be called.
					[p,pdata] = ProcessSession(eval(class(obj)),varargin{:});
					robj = plus(robj,p,varargin{:});
					if(~isempty(Args.DataPlusCmd))
						eval(Args.DataPlusCmd);
					end
					cd ..
				end
			end
		end    
	else
		eval(Args.nptSiteCmd);
	end    
    % create marker if necessary
    createProcessedMarker(obj,'site');   
end % if marker file exists
