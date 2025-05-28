function [robj,data] = ProcessDirs(obj,varargin)
%nptdata/ProcessDirs Process directories in nptdata object
%   [ROBJ,OBJ2] = ProcessDirs(OBJ,'Object',OBJECTNAME)
%   instantiates an object of the OBJECTNAME class in each directory 
%   in OBJ using the 'auto' flag, and the remaining values in the Object 
%   cell array as optional input arguments. The plus method for the  
%   OBJECT class is then called, along with any optional input arguments, 
%   to add all the objects together and the result is returned in OBJ2.
%      e.g. [nd,mf] = ProcessDirs(nd,'Object','mapfields', ...
%      'FieldMark',1});
%
%   ROBJ = ProcessDirs(OBJ,'nptDirCmd',CMD) changes directory to each
%   of the sessiondirs in OBJ and evaluates CMD.
%      e.g. ProcessDirs(nd,'nptDirCmd','eyejitter(''auto'',''save'');')
%
%   [ROBJ,DATA] = ProcessDirs(OBJ,'nptDirCmd',CMD) returns any data from
%   CMD. DATA is initialized to [] at the start of the function and it 
%   is up to the user to fill it with relevant data. The variable i can 
%   also be used to keep track of the directories in OBJ if there might
%   be more than one row of data for each directory.
%      e.g. [ndall,d] = ProcessDirs(ndall,'nptDirCmd','ecc = ...
%         getEccentricity(mapfields(''auto''),''Mark'',1); ...
%         data = [data; repmat(i,length(ecc),1) ecc];')
%   will return both the index in ndall and the eccentricities of the
%   fields for each directory in ndall. Note that accessing fields in
%   objects that inherit from other objects using the following command 
%   in nptDirCmd will not work:
%      mf = mapfields('auto'); data = [data; mf.data.numRFs];
%   Instead, use the following form:
%      data = [data; get(mapfields('auto'),'NumRFs')];
%   or:
%      mf = mapfields('auto'); a(1) = struct('type','.','subs','data');
%         a(2) = struct('type','.','subs','numRFs'); 
%         data = [data; subsref(mf,a)];
%
%   [ROBJ,DATA] = ProcessDirs(OBJ,'nptDirCmd',CMD,'DataInit',DATA_INIT)
%   initializes DATA to DATA_INIT so other variable types like cell 
%   arrays or structures may be used. 
%      e.g. [nd,dirs] = ProcessDirs(nd,'DataInit',{}, ...
%      'nptDirCmd','data = {data{:} pwd length(nptDir)};');


Args = struct('nptDirCmd','','Object','','DataInit',[],'RedoValue',0);
Args = getOptArgs(varargin,Args,'shortcuts',{'Reprocess',{'RedoValue',1}});

robj = obj;

% check if we are creating objects
if(~ischar(Args.Object))
	error('Object argument needs to be a string!');
elseif(~isempty(Args.Object))
	% create empty object
	data = feval(Args.Object);
	useObj = 1;
else
	data = Args.DataInit;
	useObj = 0;
end

% get directories in obj
if(isa(obj,'nptdata'))
	sdirs = subsref(obj,struct('type','.','subs','SessionDirs'));
else
	sdirs = obj.SessionDirs;
end
% get number of directories in obj
ndirs = length(sdirs);
% get current directory
cwd = pwd;
for i = 1:ndirs
	fprintf('Processing %s\n',sdirs{i});
    temp = sdirs{i};
    temp = temp(1:end-14);
	cd(temp)
    % check for skip.txt
    if(~checkMarkers(obj,Args.RedoValue,'dirs'))
		if(useObj)
			% call the functional form of plus so we can pass additional
			% flags to it. Also pass the optional input arguments to the
			% constructor of the object.
			data = plus(data,feval(Args.Object,'auto', ...
				varargin{:}),varargin{:});
		else
			eval(Args.nptDirCmd);
		end
    else
        fprintf('Skipped!\n');
    end
	cd(cwd);
end
