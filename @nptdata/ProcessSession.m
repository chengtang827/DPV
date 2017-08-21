function [robj,data] = ProcessSession(obj,varargin)
%NPTDATA/ProcessSession	Process session data.
%   ROBJ = ProcessSession(OBJ) checks the local directory for data to 
%   process and returns the processed object in ROBJ. It does the 
%   following:
%      a) Checks the local directory for the presence of files named
%   either skip.txt or processedsession{classname}.txt. If either are 
%   present, the function will exit, unless the argument 'redo' is 
%   present.
%      b) Changes directory to each group directory and calls 
%   ProcessGroup(OBJ).
%      c) Creates processedsession{classname}.txt in the local directory.
%
%   ProcessSession(OBJ,ARG1,ARG2,...) takes the following optional 
%   arguments, which are also passed to ProcessTrial:
%      'Reprocess'      If this is the only argument, the function 
%                       performs all operations even if 
%                       processedsession.txt is present.
%      'Groups'         Processes the specified groups instead of all
%                       groups found in the session directory.
%      'SkipGroups'     Skips the directories specified in a cell array.
%                       This option cannot be used together with the 
%                       Groups option.
%      'nptSessionCmd'  Performs the following command for each
%                       session. Be sure to set the output variable
%                       robj if the nptdata object created is to be 
%                       added to other objects.
%      'SessionTrials'  Flag to indicate that ProcessTrial should be
%                       called instead of ProcessGroup.
%      'GroupDirName'   Specifies string pattern to use to search for 
%                       group directories (default: 'group*').
%      'SessionObject'  Flag that indicates that the object should be
%                       instantiated at this level.
%      e.g. ProcessSession(nptdata,'nptSessionCmd',...
%           'cd SORT; RunClustBatch(''Matlab/MClust/Batch/Batch_KKwikEE.txt'',
%           ''Do_AutoClust'',''no''); cd ..'); 
%      e.g. ProcessSession(nptdata,'nptSessionCmd',...
%           'robj = nptdata(0,0,''Eval'',''ispresent(''''performance.mat'''',''''file'''')'');');
%
%	Dependencies: @nptdata/checkMarkers, @nptdata/createProcessedMarker, 
%      @nptdata/ProcessTrial. 

Args =  struct('RedoValue',0,'nptSessionCmd','','SessionTrials',0, ...
	'Groups','','SkipGroups','','DataInit',[],'GroupDirName','group*', ...
	'SessionObject',0,'AnalysisLevel','','DataPlusCmd','');
Args = getOptArgs(varargin,Args,'flags',{'SessionTrials','SessionObject'}, ...
	'shortcuts', {'Reprocess',{'RedoValue',1}});

% assign input object to output object so that we can just add new object
% to input object. This will also ensure that we always return an object
robj = obj;
data = Args.DataInit;

% check markers to see if we need to process this session
if (~checkMarkers(obj,Args.RedoValue,'session'))
    % check for presence of AnalysisLevel input argument
    if(isempty(Args.AnalysisLevel))
		% check the object's AnalysisLevel
		Args.AnalysisLevel = get(obj,'AnalysisLevel');
    end
	% check if object should be instantiated at the session level
	if(~Args.SessionObject)
		% SessionObject argument was not specified so check the object
		% properties
		if(strcmp(get(obj,'ObjectLevel'),'Session'))
			Args.SessionObject = 1;
		end
	end
	if(~strcmp(Args.AnalysisLevel,'Single'))
		[robj,pdata] = ProcessCellCombos(obj,varargin{:});
		if(~isempty(Args.DataPlusCmd))
			eval(Args.DataPlusCmd);
		end
	elseif(Args.SessionObject)
		robj = feval(class(obj),'auto',varargin{:});
	elseif isempty(Args.nptSessionCmd)
		if(~Args.SessionTrials)
            if(~isempty(Args.GroupDirName))
                sgroups = nptDir(Args.GroupDirName);
            else
				% loop over groups in session
				sgroups = nptDir;
            end                
			for i = 1:size(sgroups,1);
				% check to make sure it is a directory
				if(sgroups(i).isdir)
					% get name of directory
					sgroup_num = sgroups(i).name;
					% only continue if Groups is empty or dname matches Groups
					% and SkipGroups is empty or dname does not match SkipGroups
					% use shortcut form of or operator so we don't have to
					% check if Groups or SkipGroups is empty before doing the
					% skipcmpi operation
					if( (isempty(Args.Groups) || (sum(strcmpi(sgroup_num,Args.Groups))>0)) ...
					&& (isempty(Args.SkipGroups) || sum(strcmpi(sgroup_num,Args.SkipGroups))==0) )
						fprintf(['\t\t\tProcessing Group ' sgroup_num '\n']);
						cd(sgroup_num)
						[p,pdata] = ProcessGroup(eval(class(obj)),varargin{:});
						robj = plus(robj,p,varargin{:});
						if(~isempty(Args.DataPlusCmd))
							eval(Args.DataPlusCmd);
						end
						cd ..
					end
				end
			end
		else
			% get trials
			for i = 1:obj.number;
				[p,pdata] = ProcessTrial(obj,i,varargin{:});
				robj = plus(robj,p,varargin{:});
				if(~isempty(Args.DataPlusCmd))
					eval(Args.DataPlusCmd);
				end
			end
		end
	else
		eval(Args.nptSessionCmd);
	end
	% create marker if necessary
	createProcessedMarker(obj,'session');
else
    fprintf('\t\t\tSkipped\n');
end % if marker file exists
