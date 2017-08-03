function r = cell2array(c)
%cell2array Converts cell array to matrix padded by NaN
%   R = cell2array(C) converts the cell array C into a matrix
%   with the unequal entries padded by NaN.

% check size of c
[crows,ccols] = size(c);
if(crows==1 | ccols==1)
	% get number of columns in the cell array
	csize = length(c);
	% get the length of each cell element
	clength = cellfun('length',c);
	% get the maximum length
	maxcl = max(clength);
	% create matrix with maxcl NaN's
	r = repmat(nan,maxcl,csize);
	for i = 1:csize
		r(1:clength(i),i) = vecc(c{i});
	end
else
    error('One of the dimensions has to be 1!')
end
