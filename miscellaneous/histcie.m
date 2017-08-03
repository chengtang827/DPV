function [n,bin] = histcie(x,edges,varargin)
% HISTCIE Histogram count including end point
%   [N,BIN] = HISTCIE(X,EDGES) is the same as the MATLAB function
%   HISTC except it adds the last value returned from HISTC (i.e.
%   number of values of X that match EDGES(end)) to the second 
%   last bin and sets the last bin to zero. The last value is
%   returned in N so that the function BAR(EDGES,N,'histc') can
%   still be used to create plots easily. BIN is also modified so
%   that any value in X matching EDGES(end) will be set to bin
%   length(EDGES)-1. HISTCIE will also return a zero vector in N 
%   as well as an empty matrix in BIN if X is empty.
%
%   [N,BIN] = HISTCIE(X,EDGES,'DropLast') drops the last value in
%   N, which is always 0.
%
%   [N,BIN] = HISTCIE(X,EDGES,'DataCols') forces the analysis to
%   use the row vector in X as separate data series with one data
%   point each.

Args = struct('DropLast',0,'DataCols',0);
Args = getOptArgs(varargin,Args,'flags',{'DropLast','DataCols'});

% check if x is empty
if(isempty(x))
    % return all zeros in n and emtpy matrix in bin
    nh = zeros(size(edges));
    % make sure nh is a column vector
    nh = vecc(nh);
    binh = [];
else
    % get size of x
    [xrows,xcols] = size(x);    
    % check if it is a row vector
    if( (xrows==1) && (xcols>1) )
        if(Args.DataCols) 
            % add a row of NaN's to make sure the data is treated as
            % columns
            x = concatenate(x,NaN);
        else
            % switch x to column vector
            x = vecc(x);
        end
    end
	[nh,binh] = histc(x,edges);
	% make sure nh is a column vector, especially when x is 1x1
	nh = vecc(nh);
	% find length of n
    nhl = size(nh,1);
	% get second last index
	nh1 = nhl - 1;
	% add last value to second last value
	nh(nh1,:) = nh(nh1,:) + nh(nhl,:);
	% set last value to zero
	nh(nhl,:) = 0;
	% find binh == edges(end) and set them to nhl - 1 (i.e. nh1)
    bfi = find(binh==nhl);
    if(~isempty(bfi))
    	binh(bfi) = nh1;
    end
end

% if there were no output arguments, behave like hist and plot the histogram
if (nargout == 0)
	bar(edges,nh,'histc')
else
	if(Args.DropLast)
		% return output arguments with last value dropped
		n = nh(1:(end-1),:);
	else
		n = nh;
	end
	bin = binh;	
end
