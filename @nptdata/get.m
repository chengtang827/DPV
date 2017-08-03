function p = get(n,varargin)
%NPTDATA/GET Returns nptdata object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object property specified by
%   PROP_NAME. PROP_NAME can be one of the following:
%      'Number'
%      'HoldAxis'
%
%   Dependencies: None.

Args = struct('Number',0,'HoldAxis',0,'SessionDirs',0, ...
	'GroupPlotProperties',0,'AnalysisLevel',0,'ObjectLevel',0);
Args = getOptArgs(varargin,Args,'flags',{'Number','HoldAxis', ...
	'SessionDirs','AnalysisLevel','ObjectLevel'});
	
if(Args.Number)
	p = n.number;
elseif(Args.HoldAxis)
	p = n.holdaxis;
elseif(Args.SessionDirs)
	p = n.sessiondirs;
elseif(Args.GroupPlotProperties)
	p.separate = 'No';
elseif(Args.AnalysisLevel)
	p = 'Single';
elseif(Args.ObjectLevel)
    %p = 'Cluster';
    p = levelConvert('levelNo',1);
else
	error('Unknown property!')
end
