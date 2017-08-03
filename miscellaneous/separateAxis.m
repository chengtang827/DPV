function axesPositions = separateAxis(sAxis,numDirs)
%separateAxis Calculates axes positions
%   AXPOSITIONS = separateAxis(AXES,N) divides the current axis into
%   N axes. AXES can be 'Horizontal', 'Vertical' or 'No', in which
%   case the current axis position is replicated N times and returned
%   in AXPOSITIONS. If N is 1, the current axis position is returned.

% get position of current axis
axpos = get(gca,'Position');

if(numDirs==1)
	axesPositions = axpos;
elseif(strcmpi(sAxis,'No'))
	axesPositions = repmat(axpos,numDirs,1);
elseif(strcmpi(sAxis,'Horizontal'))
	% divide width, which is the 3rd entry in axpos, into numDirs
	subwidth = axpos(3)/numDirs;
	% generate starting x-positions
	startx = axpos(1):subwidth:(axpos(1)+axpos(3));
	axesPositions = [startx(1:(end-1))' repmat(axpos(2),numDirs,1) ...
			repmat(subwidth,numDirs,1) repmat(axpos(4),numDirs,1)];
elseif(strcmpi(sAxis,'Vertical'))
	% divide height, which is the 4th entry in axpos, into numDirs
	subheight = axpos(4)/numDirs;
	% generate starting y-positions
	starty = axpos(2):subheight:(axpos(2)+axpos(4));
	axesPositions = [repmat(axpos(1),numDirs,1) starty(1:(end-1))' ...
			repmat(axpos(3),numDirs,1) repmat(subheight,numDirs,1)];
end
