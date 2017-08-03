function vc = vecc(a)
%VECC Convert to column vector
%   V = VECC(A) checks A to see if it is a 1 by N vector and converts
%   it to a N by 1 vector. Otherwise, the function returns A.

% get size of a
as = size(a);
% take transpose only if number of row is 1 and number of columns is
% greater than 1
if( (as(2)>1) && (as(1)==1) )
	vc = a';
else
	vc = a;
end
