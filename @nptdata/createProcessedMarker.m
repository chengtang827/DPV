function createProcessedMarker(obj,type)
%NPTDATA/createProcessedMarker Creates a processed marker
%   createProcessedMarker(OBJ,TYPE) creates a file that
%   is used to indicate that the data has been processed.
%   TYPE can be either: 'days','day','session'.
%
%   Dependencies: None.

if (useProcessedMarker(obj))
	cname = class(obj);
	fid=fopen(['processed' type cname '.txt'],'wt');
	fclose(fid);
end
