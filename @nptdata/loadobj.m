function b = loadobj(a)
%@sesinfo/nptdata Function to update old saved objects

if(isa(a,'nptdata'))
	b = a;
else
	% a is a structure
	if(~isfield(a,'sessiondirs'))
		% add sessiondirs filed added 2/20/04
		a.sessiondirs = {};
		b = class(a,'nptdata');
	end
end
