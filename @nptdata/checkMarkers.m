function res = checkMarkers(obj,redo,type)
%NPTDATA/checkMarkers Checks for markers indicating whether 
%      data should be processed
%   RES = checkMarkers(OBJ,REDO,'session') checks for the following
%   markers: skip.txt, skip{classname}.txt, processedsession{classname}.txt
%   to see if data should be processed ({classname} is obtained
%   from OBJ). It returns 1 if any of the marker files is present, and
%   0 otherwise. If the REDO argument is 1, processedsession{classname}.txt
%   is ignored.
%
%   RES = checkMarkers(OBJ,REDO,'day') looks for processedday{classname}.txt
%   instead to check to see if data should be processed.
%
%   RES = checkMarkers(OBJ,REDO,'days') looks for processeddays{classname}.txt
%   instead to check to see if data should be processed.
%
%   Dependencies: nptDir.

% should we skip completely
marker = nptDir('skip.txt');
% get class name
cname = class(obj);
% should we skip for this object
marker = [marker nptDir(['skip' cname '.txt'])];
if (useProcessedMarker(obj))
	% check for processed{type}{classname}.txt unless redo is 1
	if redo==0
		marker=[marker nptDir(['processed' type cname '.txt'])];
	end
end

if isempty(marker)
	res = 0;
else
	res = 1;
end
