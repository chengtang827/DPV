function Inspect(obj,varargin)
%NPTDATA/INSPECT Plots data
%   INSPECT(OBJECT,PROPERTIES) is a function that can be used to view 
%   any data derived from the NPTDATA and EVENT classes. PROPERTIES 
%   contain pairs of properties and values which may any of the 
%   following:
%      Property      Values
%      'HoldAxis'	'true','false'
%
%   Dependencies: @event/event.

if ~isempty(obj)
	ev = event(1,get(obj,'Number'));
	% get default hold axis behavior from object
	holdaxis = get(obj,'HoldAxis');
	
	% parse input argument to see if we need to overide object's HoldAxis property
	property_argin = varargin;
	plength = length(property_argin);
	while plength >= 2,
		prop = property_argin{1};
		val = property_argin{2};
		if plength > 2
			property_argin = property_argin(3:end);
			plength = length(property_argin);
		else
			plength = 0;
		end

		switch prop
		case 'HoldAxis'
			if strcmp(val,'true')
				holdaxis = 1;
			else
				holdaxis = 0;
			end
		otherwise
			error('Unknown property argument');
		end
	end
	
	obj = plot(obj,1);
	
	if holdaxis
		ax = axis;
		lm = limits(ax(3),ax(4));
	end
	
	while 1
		% get keyboard input to see what to do next
		key = input('RETURN - Next waveform; p - Previous waveform; N - waveform N; q - Quit: ','s');
		n = str2num(key);
		if strcmp(key,'p')
			[n,ev] = Decrement(ev);
		elseif strcmp(key,'q')
			break;
		elseif ~isempty(n)
			ev = SetEventNumber(ev,n);
		else
			[n,ev] = Increment(ev);
		end
		obj = plot(obj,n);
		if holdaxis
			ax = axis;
			[lm,lmin,lmax] = update(lm,ax(3),ax(4));
			axis([ax(1) ax(2) lmin lmax]);
		end
	end
end