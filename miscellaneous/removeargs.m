function [rargs,num_args] = removeargs(args,i,number)
%REMOVEARGS Remove arguments from list

nargs = size(args,2);

vmin = i - 1;
vmax = i + number;
if vmin > 0
	v1 = {args{1:vmin}};
else
	v1 = {};
end
if vmax <= nargs
	v2 = {args{vmax:nargs}};
else
	v2 = {};
end

rargs = {v1{:},v2{:}};
num_args = nargs - number;
