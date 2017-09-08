function dir = getPrefDir
%get path of this function
ppdir = mfilename('fullpath');
%get the root

%different methods on Windows and Linux
if strncmp(computer,'PC',2)
    %On windows
    parts = split(ppdir, filesep);
    dpv_prefdir_p = join(parts(1:end-2),filesep);
    dpv_prefdir = dpv_prefdir_p{1};
else  % isunix
    parts = strsplit(ppdir, filesep);
    dpv_prefdir_p = strjoin(parts(1:end-2),filesep);
    dpv_prefdir = dpv_prefdir_p;
    
end
dir = dpv_prefdir;

end