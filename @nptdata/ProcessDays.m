function [robj,data] = ProcessDays(obj,varargin)
%NPTDATA/ProcessDays Process an animal's data.
%	ROBJ = ProcessDays(OBJ) checks the local directory for data to 
%   process and returns the processed object in ROBJ. It does the
%   following:
%      a) Checks the local directory for the presence of files named
%   either skip.txt or processeddays{classname}.txt. If either are 
%   present, the function will exit, unless the argument 'redo' is 
%   present.
%      b) Changes directory to each day directory and calls
%   ProcessDay(OBJ).
%      c) Creates processeddays{classname}.txt in the local directory.
%
%   ProcessDays(OBJ,ARG1,ARG2,...) takes the following optional arguments,
%   which are also passed to ProcessDay:
%      'Reprocess'   If this is the only argument, the function 
%                    performs all operations even if processeddays.txt 
%                    is present.
%   The following optional arguments are only used by this function:
%      'Days'	     Processes selected days instead of all 
%                    days found in the local directory. This 
%                    argument must be followed by a cell array 
%                    containing a list of day names, 
%                    e.g. {'061602','072002'}.
%      'SkipDays'    Skips the directories specified in a cell array.
%                    This option cannot be used together with the Days
%                    option.
%
%	Dependencies: removeargs, nptDir, ProcessDay.

Args = struct('RedoValue',0,'Days','','SkipDays','','DataInit',[], ...
	'DataPlusCmd','','nptDaysCmd','');
Args = getOptArgs(varargin,Args,'shortcuts',{'Reprocess',{'RedoValue',1}});

robj = obj;
data = Args.DataInit;

if (~checkMarkers(obj,Args.RedoValue,'days'))
	if(isempty(Args.nptDaysCmd))
		dirlist=nptDir;
		for i=1:size(dirlist,1)		%loop over days
			if(dirlist(i).isdir)
				% get name of directory
				dname = dirlist(i).name;
				% only continue if Days is empty or dname matches Days
				% and SkipDays is empty or dname does not match SkipDays
				% use shortcut form of or operator so we don't have to
				% check if Days or SkipDays is empty before doing the
				% strcmpi operation
				if( (isempty(Args.Days) || (sum(strcmpi(dname,Args.Days))>0)) ...
				&& (isempty(Args.SkipDays) || sum(strcmpi(dname,Args.SkipDays))==0) )
					fprintf(['Processing Day ' dname '\n']);
					cd (dname)
					% use eval(class(obj)) to create empty object so the 
					% correct ProcessDay will be called.
					[p,pdata] = ProcessDay(eval(class(obj)),varargin{:});
					robj = plus(robj,p,varargin{:});
					if(~isempty(Args.DataPlusCmd))
						eval(Args.DataPlusCmd);
					end
					cd ..
				end
			end
		end
	else
		eval(Args.nptDaysCmd);
	end

	% create marker if necessary
	createProcessedMarker(obj,'days');	
end
