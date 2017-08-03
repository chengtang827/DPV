function n = set(n,prop_name,p)
%NPTDATA/SET Sets nptdata object properties
%   OBJ = SET(OBJ,PROP_NAME,VALUE) sets an object property specified by
%   PROP_NAME to VALUE. PROP_NAME can be one of the following:
%      'Number' - p must be number.
%      'HoldAxis' - p must be 0 or 1. 
%      'SessionDirs' - p must be cell array of strings.
%
%   Dependencies: None.

switch prop_name
case 'Number'
	n.number = p;
case 'HoldAxis'
	n.holdaxis = p;
case 'SessionDirs'
	if(~iscell(p))
		p = {p};
	end
    n.sessiondirs = p;
    % make sure we update the number field
    n.number = size(p,2);
otherwise
	error([prop_name 'is not a valid nptdata property'])
end
	