function [obj,res] = subsasgn(obj,index,value)
%NPTDATA/SUBSASGN Assignment function for NPTDATA object.
%
%   Dependencies: None.

res = 1;
myerror = 0;

switch index(1).type
case '.'
	switch index(1).subs
	case 'number'
		obj.number = value;
	case 'holdaxis'
		obj.holdaxis = value;
	case 'SessionDirs'
		if(indlength==1)
			obj.sessiondirs = value;
		else
			obj.sessiondirs = subsasgn(obj.sessiondirs,index(2:end),value);
        end
	otherwise 
		% since nptdata does not inherit from any other object
		% go ahead and indicate error
		myerror = 1;
	end
otherwise
	myerror = 1;
end

if myerror == 1
	if isempty(inputname(1))
		% means some other function is calling this function, so
		% just return error instead of printing error
		res = 0;
	else
		error('Invalid field name')
	end
end
