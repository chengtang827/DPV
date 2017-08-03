function [r,varargout] = get(obj,varargin)
%nptgroup/get Get function for nptgroup objects

Args = struct('Object','','GroupEvent',0,'Number',0);
[Args,varargin] = getOptArgs(varargin,Args,'flags',{'GroupEvent', ...
	'Number'}, ...
    'remove',{'GroupEvent'});

% set variables to default
r = [];

if(Args.GroupEvent & Args.Number) 
	r = obj.data.numSets;
elseif(~isempty(Args.Object) & Args.Number)
	plotObject = Args.Object;
	% get number of columns in Object cell array
	[oRows,oCols] = size(plotObject);
	cwd = pwd;
    cd(obj.data.setNames{1})
%     cd(obj.data.cellNames{1})
    if(oCols>2)
		% instantiate the object with specified optional arguments
		pObject = feval(plotObject{1},'auto',plotObject{3}{:});
		% call the get function for the object with the optional
		% arguments for plot
		r = get(pObject,'Number',plotObject{2}{:});
	elseif(oCols>1)
		% instantiate the object without optional arguments
       
		pObject = feval(plotObject{1},'auto');
		% call the get function for the object with the optional
		% arguments for plot
		r = get(pObject,'Number',plotObject{2}{:});
	else
		% instantiate the object without optional arguments
		pObject = feval(plotObject{1},'auto');
		% call the get function for the object without optional
		% arguments
		r = get(pObject,'Number');
	end	
    cd(cwd);
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.nptdata,varargin{:});
end
