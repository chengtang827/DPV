function [robj,data] = ProcessCell(obj,varargin)
%NPTDATA/ProcessCell Process cell data
%   ROBJ = ProcessCell(OBJ,TRIAL) performs computations specific to OBJ
%   and returns the processed object ROBJ. 
%
%	Dependencies: None.

Args =  struct('RedoValue',0,'nptCellCmd','','DataInit',[],'DataPlusCmd','');
Args = getOptArgs(varargin,Args,'shortcuts', ...
		{'Reprocess',{'RedoValue',1}});

% assign input object to output object so that we can just add new object
% to input object. This will also ensure that we always return an object
robj = obj;
data = Args.DataInit;

% check markers to see if we need to process this session
if (~checkMarkers(obj,Args.RedoValue,'cell'))
	if isempty(Args.nptCellCmd)
		robj = feval(class(obj),'auto',varargin{:});
	else
		eval(Args.nptCellCmd);
	end
end % if marker file exists
