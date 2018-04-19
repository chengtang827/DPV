function dir = getPrefDir
%get path of this function
ppdir = mfilename('fullpath');
%get the root


parts = strsplit(ppdir, filesep);
dpv_prefdir_p = strjoin(parts(1:end-2),filesep);
dpv_prefdir = dpv_prefdir_p;


dir = dpv_prefdir;

end