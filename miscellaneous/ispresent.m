function [res,aname] = ispresent(name,type,varargin)
%ISPRESENT Checks if file or directory exists
%   ISPRESENT('A','file') returns 1 if A exists and is a file.
%   ISPRESENT('A','dir') returns 1 if A exists and is a directory.
%   Otherwise, the function returns 0.
%
%   [RES,ANAME] = ISPRESENT(NAME,TYPE,'CaseInsensitive') ignores 
%   case when checking the names of a file or directory. If NAME 
%   is found, the actual name that is found is returned in ANAME.
%
%   [RES,ANAME] = ISPRESENT(NAME,TYPE,'CaseInsensitiveSuffix') 
%   ignores case only for the suffix when checking the names of a 
%   file or directory. If NAME is found, the actual name that is 
%   found is returned in ANAME.
%
%   Dependencies: nptDir, nptFileParts.

% look for optional arguments
ignorecase = 0;
ignoresuffixcase = 0;
% subtract first two non optional arguments
num_args = nargin - 2;
i = 1;
while(i <= num_args)
    if ischar(varargin{i})
		switch varargin{i}
		case('CaseInsensitive')
			ignorecase = 1;
		case('CaseInsensitiveSuffix')
			ignoresuffixcase = 1;
		otherwise
			error('Unknown input argument');
		end
	end
    i = i + 1;
end

% we cannot just do nptDir since if we do ispresent(name,'file') and
% name is a directory, nptDir will return the contents of the directory
% and this function will return a false positive. In this scenario, if 
% we do ispresent(name,'dir'), it will also return a false negative.

% find if name consists of a path
[path,filename,suffix] = nptFileParts(name);
if (isempty(path))
	% do a nptDir in the current directory
	a = nptDir;
else
	% do a nptDir in the path directory
	a = nptDir(path);
end

% can't ignore suffix case if there is no suffix
if (ignoresuffixcase & isempty(suffix))
	error('No suffix found. Cannot perform CaseInsensitiveSuffix.');
end

if ignorecase
	fname = [filename suffix];
	lf = lower(fname);
	uf = upper(fname);
elseif ignoresuffixcase
	lf = [filename lower(suffix)];
	uf = [filename upper(suffix)];
else
	% separate out filename and suffix from path to compare
	% with directory listing later
	fname = [filename suffix];
end

% find length of a
asize = length(a);
% initialize res to 0 so we will return 0 if we went through the whole 
% loop without finding name
res = 0;
aname = '';
if (ignorecase | ignoresuffixcase)
	for i = 1:asize
		if (strcmp(lf,lower(a(i).name)) | strcmp(uf,upper(a(i).name)))
			% name exists, but need to check type
			isdir = a(i).isdir;
			if (strcmp(type,'file') & (isdir == 0))
				res = 1;
				aname = a(i).name;
			elseif (strcmp(type,'dir') & (isdir == 1))
				res = 1;
				aname = a(i).name;
			end
			% break out of for loop since there can't be more than one
			% item with the same name
			break;
		end
	end
else
	for i = 1:asize
		if (strcmp(fname,a(i).name))
			% name exists, but need to check type
			isdir = a(i).isdir;
			if (strcmp(type,'file') & (isdir == 0))
				res = 1;
				aname = a(i).name;
			elseif (strcmp(type,'dir') & (isdir == 1))
				res = 1;
				aname = a(i).name;
			end
			% break out of for loop since there can't be more than one
			% item with the same name
			break;
		end
	end
end
% if there is a path, add the path to aname
if(~isempty(path))
    aname = [path filesep aname];
end
