function [robj,data] = ProcessTrial(obj,n,varargin)
%NPTDATA/ProcessTrial Process trial data
%   ROBJ = ProcessTrial(OBJ,TRIAL) performs computations specific to OBJ
%   and returns the processed object ROBJ. 
%
%	Dependencies: None.

Args = struct('RedoValue',0,'nptTrialCmd','','DataInit',[],'DataPlusCmd','');
Args = getOptArgs(varargin,Args,'shortcuts',{'Reprocess',{'RedoValue',1}});

robj = obj;
data = Args.DataInit;

% check markers to see if we need to process this session
if (~checkMarkers(obj,Args.RedoValue,'trial'))
	if isempty(Args.nptTrialCmd)
		robj = feval(class(obj),'auto',varargin{:});
	else
		eval(Args.nptTrialCmd);
	end
end % if marker file exists
