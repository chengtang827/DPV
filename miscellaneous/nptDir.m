function a = nptDir(varargin)
%nptDir Platform independent version of DIR.
%   nptDir directory_name lists the files in the current directory. 
%   When used with no arguments, nptDir acts like the DIR function in 
%   Matlab, except it will remove entries that begin with a period, 
%   e.g. '.', '..', and any hidden files created on Unix operating 
%   systems. 
%
%   nptDir('directory_name') lists the files in a directory. Pathnames 
%   and wildcards may be used. By default, this function is case
%   sensitive on non-Windows systems. 
%      e.g. nptDir('*.ini')
%   will return a list consisting of files different from 
%   nptDir('*.INI').
%
%   nptDir('directory_name','CaseInsensitive') will return a list of 
%   case insensitive files that match 'directory_name'. This will have
%   no effect on Windows systems. 
%
%   D = nptDIR('directory_name') returns the results in an M-by-1
%   structure with the fields: 
%      name  -- filename
%      date  -- modification date
%      bytes -- number of bytes allocated to the file
%      isdir -- 1 if name is a directory and 0 if not

Args = struct('CaseInsensitive',0);
Args.flags = {'CaseInsensitive'};
Args = getOptArgs(varargin,Args);

ignorecase = 0;
% get platform
platform = computer;
if(strcmp(platform,'PCWIN'))
    osnum = 0;
elseif(strcmp(platform,'MAC'))
    osnum = 1;
else
    osnum = 2;
end

switch nargin
case 0
	% no argument so we are going to list all files
	% directory listings without arguments work fine on Windows share
	% directories mounted on Mac OS X so we don't need to do anything
	% special
	dirlist = dir;
case {1,2}
    if(osnum == 0)
    	% Windows machine so ignore the second argument
        dirlist = dir(varargin{1});
    else
    	% non-Windows machine so use workaround to do listing
    	% tecnically dir works on Windows shares mounted on Linux
    	% but we will use the workaround since it simplifies dealing
    	% with the case-sensitivity issue
        dirlist = doDir(varargin{1},Args);
    end
otherwise
	error('Too many input arguments');
end

dirsize = size(dirlist,1);
a = [];
for i = 1:dirsize
	if ~strcmp(dirlist(i).name(1),'.')
		% first entry is a '.', which means that we should remove
		% it from our list
		a = [a; dirlist(i)];
	end
end

function dirlist = doDir(matchstr,Args)

% check if matchstr consists of a path
[p,n,e] = nptFileParts(matchstr);
% check if we were supposed to just list all the files in another
% directory. If matchstr was something like '..' or '../..' then the
% matlab function fileparts used in nptFileParts returns n as '.' and 
% e as '.'. So we need to fix that before we continue.
if(strcmp(n,'.') && strcmp(e,'.'))
	if(isempty(p))
		p = '..';
	else
		p = [p filesep '..'];
	end
	% set n and e to empty string so we know to just return the entire dir 
	% listing
	n = '';
    e = '';
end
% temporary fix for bug in MATLAB when listing directories on a
% mounted Windows share on MAC OS X
cwd = '';
if(~isempty(p))
    % save current directory
    cwd = pwd;
    % change to path
    cd(p)
	% get directory listing
	list = dir;
    % change back to previous directory so we don't change
    % directories on the user without them knowing
    cd(cwd)
    % remove the path prefix from matchstr
    matchstr = [n e];
else
	% get directory listing
	list = dir;
end
% If matchstr was something like '../' then n would be empty so we will
% just return the dir listing
if(isempty(n))
    dirlist = list;
    return
end
% put the names in a cell array;
names = {list.name};
% parse matchstr to convert it to pattern that regexp
% recognizes
if(matchstr(1)~='*')
    % add ^ to beginning of matchstr
    matchstr = ['^' matchstr];
end
if(matchstr(end)~='*')
    % add $ to end of matchstr
    matchstr = [matchstr '$'];
end
% replace . with \.
matchstr = strrep(matchstr,'.','\.');
% replace * with .*
matchstr = strrep(matchstr,'*','.*');
if(Args.CaseInsensitive)
	% find which cells have contents that match matchstr regardless
	% of case
	goodcells = regexpi(names,matchstr);
else
	% find which cells have contents that match matchstr
	goodcells = regexp(names,matchstr);
end
% extract those cell indices from the original list
dirlist = list(~cellfun('isempty',goodcells));
