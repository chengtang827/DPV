function event = event(varargin)
%EVENT Constructor function for EVENT class
%   E = EVENT(START,END) instantiates an object that contains 
%   data and methods used by Inspect methods for a number of data
%   classes. The data structure contains the following fields:
%      E.event
%      E.end
%
%   Dependencies: None.

switch nargin
case 0
	v.start = 1;
	v.event = 1;
	v.end = 0;
	event = class(v,'event');
case 1
	if (isa(varargin{1},'event'))
		event = varargin{1};
	else
		error('Wrong argument type')
	end
case 2
	v.start = varargin{1};
	v.event = varargin{1};
	v.end = varargin{2};
	event = class(v,'event');
otherwise
	error('Wrong number of input arguments')
end
	

