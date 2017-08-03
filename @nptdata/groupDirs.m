function sessiongroups = groupDirs(obj,varargin)
%nptdata/groupDirs Groups directories
%   G = groupDirs(OBJ) returns a matrix containing indices 
%   corresponding to different grouping of the directories.
%   The default grouping is 'Intra<Level>', which returns the indices
%   corresponding to each item in the <level> in each column, padded with NaN's.
% 
% LevelPrefix:  specifies the level name of 'Intra<Level>'. If not specified, 
%   the function returns the grouping in second lowest level. 
%   e.g.: groupDirs(obj,'Pairs','LevelPrefix','Group');
%         gives IntraGroup grouping, returns the indices
%   corresponding to each group in each column.
%
%   An example of how to use the matrix returned from this function
%   is shown below:
%       sg = groupDirs(obj);
%       % get values
%       a = obj.data.responsiveness;
%       % use index to get values
%       avals = nanindex(a,sg);
%       % compute standard deviation
%       respSTD = nanstd(avals);

Args = struct('Pairs',0,'NoSingles',0,'LevelPrefix','');
Args.flags = {'Pairs','NoSingles'};
Args = getOptArgs(varargin,Args);

if(isempty(Args.LevelPrefix))
    levelPrefix = levelConvert('levelNo',1);
elseif(levelConvert('levelName',Args.LevelPrefix) == 1)
    error('Cannot create intra-%s directories...', lower(Args.LevelPrefix))
else
    levelPrefix = levelConvert('levelNo',(levelConvert('levelName',Args.LevelPrefix))-1);
end
if Args.Pairs % Analysis of Cell Pairs
    % get list of groups
    cellprefix = getDataOrder('LevelPrefix',levelPrefix);
    s = get(obj,'SessionDirs');
    % remove cluster01s etc so we get pathnames up to the group
    s1 = regexprep(s,[filesep cellprefix '.*'],'');
    % get the unique session directories and the corresponding indices
    [glist,s2i,s2j]  = unique(s1);
    % find the max number of sessions
    gnum = length(glist);
    for i = 1:gnum
        clusternum(i) = length(find(s2j==i));
    end
    % only continue if the clusterlist is not empty
    if(~isempty(clusternum))            
        if get(obj,'Number')~=sum(clusternum)
            fprintf('Error in cluster numbers')
            sessiongroups = [];
            return
        end
        index_num = 1;
        cum_clust = cumsum(clusternum);
        sessiongroups=[];
        for c_num = 1:gnum
            index_nums = index_num:1:cum_clust(c_num);
            index_num = cum_clust(c_num)+1;
            if clusternum(c_num)>1
                for c1 = 1:length(index_nums)
                    for c2 = c1+1:length(index_nums)
                        sessiongroups = [sessiongroups [index_nums(c1);index_nums(c2)]];
                    end
                end                
            end     
        end
    end        
else
    s = get(obj,'SessionDirs');
    if(~isempty(s))
        % check if the session directory contains the string combinations
        if(isempty(strfind(s{1},getDataOrder('ComboPrefix'))))
            % AnalysisLevel for the object is probably Single so proceed to
            % group single directories
            cellprefix = getDataOrder('LevelPrefix',levelPrefix);
            % remove cluster01s etc so we get pathnames up to the group
            s1 = regexprep(s,[filesep cellprefix '.*'],'');
            % get the unique group directories and the corresponding indices
            [grps,grpa,grpb] = unique(s1);
            % get number of unique groups
            gpn = length(grps);
            % calculate largest possible number of rows i.e. every group
            % had 1 member except one group which had the rest
            tmpsgrows = length(grpb) - gpn - 1;
            % create array to store temporary sessiongroups so we don't
            % have to keep changing the size of sessiongroups
            tmpsg = repmat(nan,tmpsgrows,gpn);
            % replace each column with real data
            sgrows = 0;
            for groupi = 1:gpn
                % use vecc to make sure sessioni is a column vector
                sessioni = vecc(find(grpb==groupi));
                % get length of sessioni so we can keep track of the
                % number of rows in tmpsg that is truly from the data
                sl = length(sessioni);
                tmpsg(1:sl,groupi) = sessioni;
                % store sl if it is larger than sgrows
                if(sl>sgrows)
                    sgrows = sl;
                end
            end
            % select the real data from tmpsg and return as sesiongroups
            sessiongroups = tmpsg(1:sgrows,:);
            if(Args.NoSingles)
                % take out groups containing just one cell
                sgnan = ~isnan(sessiongroups);
                sgnsum = sum(sgnan,1);
                % find columns in sgnsum that have a sum greater than 1
                sgnsi = find(sgnsum>1);
                sessiongroups = sessiongroups(:,sgnsi);
            end
        else % if(isempty(strfind(s{1},getDataOrder('ComboPrefix'))))
            % AnalysisLevel for the object is probably Pairs so group
            % combination directories
            % convert cell array s to character array so we can easily
            % get the relevant pathname (i.e. .../combinations/g2 assuming
            % we were given an intragroup object
            schar = char(s);
            % get length of path names
            sccols = size(schar,2);
            % strip the irrelevant characters off the end
            schar2 = cellstr(schar(:,1:(sccols-8)));
            % find the unique groups
            [grps,grpa,grpb] = unique(schar2);
            % get number of unique groups
            gpn = length(grps);
            % calculate largest possible number of rows i.e. every group
            % had 1 member except one group which had the rest
            tmpsgrows = length(grpb) - gpn - 1;
            % create array to store temporary sessiongroups so we don't
            % have to keep changing the size of sessiongroups
            tmpsg = repmat(nan,tmpsgrows,gpn);
            % replace each column with real data
            sgrows = 0;
            for groupi = 1:gpn
                % use vecc to make sure sessioni is a column vector
                sessioni = vecc(find(grpb==groupi));
                % get length of sessioni so we can keep track of the
                % number of rows in tmpsg that is truly from the data
                sl = length(sessioni);
                tmpsg(1:sl,groupi) = sessioni;
                % store sl if it is larger than sgrows
                if(sl>sgrows)
                    sgrows = sl;
                end
            end
            % select the real data from tmpsg and return as sesiongroups
            sessiongroups = tmpsg(1:sgrows,:);
        end % if(isempty(strfind(s{1},getDataOrder('ComboPrefix'))))
    else % if SessionDirs is empty
        sessiongroups = [];
    end % if SessionDirs is not empty
end
