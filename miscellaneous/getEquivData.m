function r = getEquivSession(varargin)
%getEquivSession Return session directory equivalent to current cluster
%   R = getEquivSession('EquivalentSessions',DIRS_CELL_ARRAY) returns
%   the directory equivalent to the current directory but for a
%   different session, i.e. for a different stimuli. The directories
%   in DIRS_CELL_ARRAY should be fully qualified since this function 
%   uses the function pwd to return the fully qualified current 
%   directory.

Args = struct('EquivalentSessions',{''},'EquiLevel','','EquivalentDir',{''});
[Args,varargin2] = getOptArgs(varargin,Args);

% get current directory
cwd = pwd;

if(~isempty(Args.EquivalentSessions))
    % get site information
    sited = getDataOrder('site');

    % find entries in EquivalentSessions with the same site
    esidx = strmatch(sited,Args.EquivalentSessions);
    if isempty(esidx)
        r=[];
        return
    end
    % get group and cluster information
    % find filesep positions in cwd
    fsidx = strfind(cwd,filesep);
    % get length of fsidx
    fsidxl = length(fsidx);
    % get string starting from the second last filesep
    gcstr = cwd(fsidx(fsidxl-1):end);

    % find entries in EquivalentSessions{esidx} with the same group and
    % cluster name
    gcstr = strrep(gcstr,'\','.');
    ridx = regexp({Args.EquivalentSessions{esidx}},gcstr);
    if isempty(ridx)
        r=[];
        return
    elseif length(ridx)==1
        esidx2=1;
    else
        esidx2 = find(~cellfun('isempty',ridx));
    end
    if(isempty(esidx2))
        r = [];
    else
        r = Args.EquivalentSessions{esidx(esidx2(1))};
    end

else
    for lowestLevel = levelConvert('levelName',Args.EquiLevel):-1:1
        if strcmp(cwd,getDataOrder('Level',levelConvert('levelNo',lowestLevel)))
            break;
        end
    end
    UpperLevel = getDataOrder('Level',lower(levelConvert('levelNo', levelConvert('levelName',Args.EquiLevel)+1)));
    esidx = strmatch(UpperLevel,Args.EquivalentDir);
%     LowerLevel = getDataOrder(lower(levelConvert('levelNo', levelConvert('levelName',Args.EquiLevel)-1)));
%     esidx1 = strmatch(LowerLevel,Args.EquivalentDir);
    if isempty(esidx)
        r=[];
        return
    end
    % find filesep positions in cwd
    fsidx = strfind(cwd,filesep);
    % get length of fsidx
    fsidxl = length(fsidx);
    % get string starting from the second last filesep
    gcstr = cwd(fsidx(fsidxl-(levelConvert('levelName',Args.EquiLevel)-lowestLevel)+1):end);
    gcstr = strrep(gcstr,'\','.');
    ridx = regexp({Args.EquivalentDir{esidx}},gcstr);
    if isempty(ridx)
        r=[];
        return
    elseif length(ridx)==1
        esidx2=1;
    else
        esidx2 = find(~cellfun('isempty',ridx));
    end
    if(isempty(esidx2))
        r = [];
    else
        r = Args.EquivalentDir{esidx(esidx2(1))};
    end
end