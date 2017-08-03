function nptMkDir(dirname)

% check to see if there is a directory named combinations
if(~isdir(dirname))
    % try creating directory
    [s,m] = mkdir(dirname);
    % check for errors
    if(~s)
        error(['Could not create ' dirname ' directory! ' m]);
    end
end
