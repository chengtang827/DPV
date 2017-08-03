function r = isempty(obj)
%nptdata/isempty True for empty nptdata objects
%   R = isempty(OBJ) returns 1 if OBJ.Number is 0 and 0 otherwise.

if(obj.number)
	r = 0;
else
	r = 1;
end
