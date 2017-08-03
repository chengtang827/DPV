function [n,v] = Decrement(v)
%EVENT/Decrement Decreases event number
%   OBJ = Decrement(OBJ) decreases the event number and returns the 
%   updated object.
%
%   Dependencies: None.

	v.event = v.event - 1;
	if v.event<v.start
		v.event = v.start;
	end
	n = v.event;