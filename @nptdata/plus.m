function r = plus(p,q,varargin)
%NPTDATA/PLUS Plus function for NPTDATA objects
%   R = PLUS(P,Q) returns the first object. This function is not
%   really meant to do anything except be sort of a virtual function
%   for inherited classes.
%
%   Dependencies: None.

% get name of class
classname = mfilename('class');

% check if first input is the right kind of object
if(~isa(p,classname))
	% check if second input is the right kind of object
	if(~isa(q,classname))
		% both inputs are not the right kind of object so create empty
		% object and return it
		r = feval(classname);
	else
		% second input is the right kind of object so return that
		r = q;
	end
else
	if(~isa(q,classname))
		% p is the right kind of object but q is not so just return p
		r = p;
	else
		% both p and q are the right kind of objects so add them 
		% together
		% assign p to r so that we can be sure we are returning the right
		% object
		r = p;
		r.number = p.number + q.number;
		r.sessiondirs = {p.sessiondirs{:} q.sessiondirs{:}};
		if(~isempty(r.sessiondirs) && size(r.sessiondirs,2)~=r.number)
			fprintf('Warning: Mismatch in sessiondirs and number!\n');
		end
	end
end
