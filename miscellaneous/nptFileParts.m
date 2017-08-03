function [path,name,ext,ver] = nptFileParts(file)
%nptFileParts Platform independent version of FILEPARTS.
%	[PATH,NAME,EXT,VER] = nptFileParts(FILE) returns the path, filename, 
%	extension and version for the specified file.  VER will be non-empty
%	only on VMS.  The only difference from the FILEPARTS function is that
%	it removes the path separator from the end of the path argument when
%	run on Classic Mac OS.
%
%	You can reconstruct the file from the parts using
%	fullfile(path,[name ext ver])

% removed ver output as it appears to have been deprecated
[path,name,ext] = fileparts(file);
if strcmp(computer,'MAC2')
	if ~isempty(path)
		plength = size(path,2);
		path = path(1:plength-1);
	end
end
