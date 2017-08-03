function [n,v] = Increment(v)
%EVENT/Increment Increases event number
%   OBJ = Increment(OBJ) increases the event number and returns the 
%   updated object.
%
%   Dependencies: None.

	v.event = v.event + 1;
	if v.event>v.end & v.end>=1
		v.event = v.end;
	end
	n = v.event;