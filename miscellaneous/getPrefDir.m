function ans = getPrefDir
    %get path of this function
    ppdir = mfilename('fullpath');
    %get the root
    parts = split(ppdir, filesep);
    dpv_prefdir_p = join(parts(1:end-2),filesep);
    dpv_prefdir = dpv_prefdir_p{1};
    ans = dpv_prefdir;
end