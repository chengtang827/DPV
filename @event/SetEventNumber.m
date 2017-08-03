function [v,n] = SetEventNumber(v,n)
%EVENT/SetEventNumber Sets the event number
%   [OBJ,NUM] = SetEventNumber(OBJ,N) sets the event number and returns
%   the updated object. If N is outside the range of OBJ.start and 
%   OBJ.end, OBJ is not changed, and OBJ.event is returned in NUM.
%
%   Dependencies: None.

% check if n is beyond the bounds of event
if( (n>=v.start) & (n<=v.end) )
	v.event = n;
else
	n = v.event;
end
