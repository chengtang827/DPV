function nptAddPath
%nptAddPath	Add paths necessary for the Neuro Physiology Toolbox
%   nptAddPath adds directories of functions necessary to run the
%   toolbox. Once this function is run, it is recommeded that the
%   path be saved so it will not be necessary to run this function
%   again.
%
%   Dependencies: None.

% fname = mfilename;
% 
% % get the location of this file
% mpath = which(fname);
% % we should really do nptFileParts instead but that might not be on the path yet
% basedir = fileparts(mpath);
% if strcmp(computer,'MAC2')
% 	if ~isempty(basedir)
% 		plength = size(basedir,2);
% 		basedir = basedir(1:plength-1);
% 	end
% end

% nptAddDirectoryToPath(basedir);
nptAddDirectoryToPath(pwd);
         

% function that will be called iteratively to add directories and 
% subdirectories
function nptAddDirectoryToPath(dname)
%nptAddDirectoryToPath Add directory and any subdirectories to path
%   nptAddDirectoryToPath(DIR_NAME) adds DIR_NAME to the path
%   and checks to see if there are any subdirectories in DIR_NAME.
%   If there are, these subdirectories are added to the path as well.
%
%   Dependencies: None.

addpath(dname);

% necessary to use myDir since if the listing contains '.' and '..'
% they will get added as well since they are directories as well
dirlist = myDir(dname);
if ~isempty(dirlist)
	dirSize = size(dirlist,1);
	for i=1:dirSize
	   % check to make sure it is a directory
	   if dirlist(i).isdir
		  % make sure it is not the doc directory or a class directory 
		  % or a CVS directory
		  if( ~strcmpi(dirlist(i).name,'doc') & isempty(findstr(dirlist(i).name,'@')) ...
		      & ~strcmpi(dirlist(i).name,'cvs') & ~strcmpi(dirlist(i).name,'documentation'))
			 nptAddDirectoryToPath([dname filesep dirlist(i).name]);
		  end
	   end
	end
end

% abbreviated version nptDir to remove dirs with '.' at the beginning
% of the name
function a = myDir(dname)

dirlist = dir(dname);
dirsize = size(dirlist,1);
a = [];
for i = 1:dirsize
	if ~strcmp(dirlist(i).name(1),'.')
		% first entry is a '.', which means that we should remove
		% it from our list
		a = [a; dirlist(i)];
	end
end
