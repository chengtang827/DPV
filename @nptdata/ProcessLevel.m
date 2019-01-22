function [robj,data] = ProcessLevel(obj,varargin)
% Levels: The name of the highest processed level.
%
% Include: Processes selected items specified in a cell array instead of all
%     items found in the local directory. This only works for items
%     in the local directory. Partial matches can be used to specify the
%     inclusion.
%
% Exclude: Skips the directories or items specified in a cell array.
%     Partial matches can be used to specify the exclusions, and items
%     in subdirectories can also be included.
%
% AnalysisLevel:  Specifies the AnalysisLevel property of OBJ.
%     Accepted values are:
%     'Single'              Individual analysis
%     'All'                 Groups of all units (a)
%     'Pairs'               Pairs of clusters.
%     'AllIntra<Element>'   Groups of intra-item elements.
%     'AllPairs'            Groups of intra-item pairs.(p)
%
% LevelObject:  Indicates that the object should be instantiated
%     at a specific level.
%
% nptLevelCmd:  Specifies the level to perform the following command for each
%     directory in that level, specified as a cell array. The
%     first element is the Level name, the second one is the
%     command.
%
% DataInit: Specifies the initial value of additional data not
%     contained in objects.
%
% DataPlusCmd: Specifies how additional data not contained in objects
%     should be combined
%
%
% Example 1:
% Only select 'a1' in level Day to process.
% a = ProcessLevel(nptdata,'Levels','Days','Include',{'a1'});
% Select both 'a2' and 'a4' in level Day to process.
% a = ProcessLevel(nptdata,'Levels','Days','Include',{'a2','a4'});
% Only process directories indicated in a cell array ndresp.SessionDirs
% a = ProcessLevel(nptdata,'Levels','Days','Include',ndresp.SessionDirs);
% Include only directories 201806??, 201807??, and exclude subdirectories
% matching sessioneye and sessiontest from processing:
% um = ProcessLevel(unitymaze,'Levels','Days','Include',{'201806','201807'}, ...
%          'Exclude',{'sessioneye','sessiontest'})
%
% Example 2:
% Combination data is going to be processed. Intra group pairs are preferred.
% a = ProcessLevel(nptdata,'Levels','Days','AnalysisRelation','IntraGroup',...
%   'AnalysisLevel','Pairs');
%
% Example 3:
% Session object is created.
% a = ProcessLevel(nptdata,'Levels','Days','LevelObject','Session');
%
% Example 4:
% [nds,data] = ProcessLevel(nptdata,'Levels','Session','Include',ndcells.SessionDirs, ...
%        'nptLevelCmd',{'Cluster','pdata = adjs2gdf;'},...
%       'DataPlusCmd','data = unique([data; pdata],''Rows'');');

Args = struct('RedoValue',0,'Levels','','Include',{''},'Exclude',{''},...
    'LevelObject','','AnalysisLevel','',...
    'DataInit',[],'nptLevelCmd',{''},'DataPlusCmd','','ArgsOnly',0);
Args.flags = {'ArgsOnly'};
Args.classname = 'ProcessLevel';
% removed the Include argument since it is supposed to apply only to the
% directory in which this function was called
[Args,varargin2] = getOptArgs(varargin,Args,'shortcuts',{'Reprocess',{'RedoValue',1}}, ...
    'remove',{'Include'});


% If user selects 'ArgsOnly', return only Args structure for an empty object
% Subtract 1 from Args.Level after processing one level.
% If the Level is greater than 1, call the function again.
% If the Level is 1, that indicates we are at the lowest level. Just do
% what ProcessCell and ProcessTrial do.

nlevel = levelConvert('levelName',Args.Levels);
checkObjectLevel = 0;
for ii = 1:nlevel
    checkObjectLevela = strcmp(get(obj, 'ObjectLevel'), levelConvert('levelNo',ii));
    checkObjectLevel = checkObjectLevel + checkObjectLevela;
end

if (Args.ArgsOnly)
    if((nlevel-1)>1)
        if (checkObjectLevel)
            [robj, Args.childArgs] = ProcessLevel(obj, 'ArgsOnly', 'Levels', levelConvert('levelNo',nlevel-1));
            Args.childArgs{2}.classname = 'ProcessLevel';
        else
            robj = obj;
        end
    elseif((nlevel-1)==1)
        robj = obj;
        data = {'Args',Args};
        return;
    end
    robj = obj;
    data = {'Args',Args};
    return;
end

robj = obj;
data = Args.DataInit;

% SelectItem and Exclude can be specified using full paths or just the
% names for this directory so we need to add the full path for the latter
% get current directory
cwd = pwd;

DirName = getDirName(nlevel-1);
% get the pathname for the SelectItem and SkipLevelItem argument
if(~isempty(Args.Include))
    % check if Include were specified with full pathnames
    % we are going to assume that either all the directories are
    % full-paths or relative-paths so we are going to just check the
    % first entry
    if(iscell(Args.Include))
        [p,n] = nptFileParts(Args.Include{1});
        SelL = length(Args.Include);
    else
        [p,n] = nptFileParts(Args.Include);
        SelL = 1;
    end
    if(isempty(p))
        % directories were specified with relative paths so we are going
        % to add the current directory to it
        %         levelnum = levelConvert('levelName',Args.SeL);
        for Includei = 1:SelL
            if(iscell(Args.Include))
                Args.Include{Includei} = [cwd filesep Args.Include{Includei}];
                % if ~isdir(Args.Include{Includei})
                % Args.Include{Includei} = cwd;
                % end
            else
                Args.Include = [cwd filesep Args.Include];
                % if ~isdir(Args.Include)
                % Args.Include = cwd;
                % end
            end
        end
    end
end

% removed code to prepend the current working directory to the Exclude entries
% so that they can be subdirectories that are excluded

varinNum = size(varargin2, 2);
% find the position of the Levels argument
for k = 1:varinNum
    if(iscellstr(varargin2(k)))
        findit = strcmp(varargin2(k),'Levels');
        if(findit)
            position = k;
        end
    end
end

% check if object should be instantiated at the specific level
if(isempty(Args.LevelObject))
    % LevelObject argument was not specified so check the object properties
    Args.LevelObject = get(obj,'ObjectLevel');
end
nLevelObject = levelConvert('levelName',Args.LevelObject);

mark1 = 0;
if(~isempty(Args.LevelObject))
    if(nLevelObject==nlevel)
        if(position==1)
            if(varinNum>2)
                robj = feval(class(obj), 'auto', varargin2{position+2:varinNum});
            else
                robj = feval(class(obj), 'auto');
            end
        elseif(position==varinNum-2)
            robj = feval(class(obj), 'auto', varargin2{1:varinNum-2});
        else
            robj = feval(class(obj), 'auto', varargin2{1:position-1},varargin2{position+2:varinNum});
        end
        mark1 = 1;
    end
end

if(mark1==0)
    if(isempty(Args.nptLevelCmd) || ...
            (~isempty(Args.nptLevelCmd) && nlevel~=levelConvert('levelName',Args.nptLevelCmd{1})))
        if(~isempty(DirName))
            list = nptDir(DirName);
        else
            list = nptDir;
        end
        for i=1:size(list,1)
            if(list(i).isdir)
                % get name of directory
                item_name = list(i).name;
                if(~strcmp(item_name,'combinations'))
                    % only continue if Include is empty or dname matches Include
                    % and Exclude is empty or dname does not match Exclude
                    % use shortcut form of or operator so we don't have to
                    % check if Exclude is empty before doing the
                    % strcmpi operation
                    go_on = 0;
                    bInclude = 0;
                    ffname = [pwd filesep item_name];
                    if( (isempty(Args.Include)) && (isempty(Args.Exclude)) )
                        go_on = 1;
                    elseif(~isempty(Args.Include))
                        % parse Include arguments
                        if(iscell(Args.Include))
                            for kk = 1:length(Args.Include)
                                if(~isempty(strfind(ffname,Args.Include{kk})))
                                    % this item matches one of the Include arguments
                                    % so continue
                                    if nlevel>=nLevelObject+1
                                        bInclude = 1;
                                        go_on = 1;
                                        % display('In include list')
                                    end
                                end  % if(~isempty(strfind(ffname,Args.Include{kk})))
                            end  % for kk = 1:length(Args.Include)
                            if(~go_on)
                                fprintf('Not in include list %s\n',ffname);
                            end
                        end  % if(iscell(Args.Include))
                    elseif(~isempty(Args.Exclude))
                        % parse Exclude arguments
                        if(iscell(Args.Exclude))
                            nExclude = length(Args.Exclude);
                            bExclude = 0;
                            for kk = 1:nExclude
                                if(~isempty(strfind(ffname,Args.Exclude{kk})))
                                    % this item matches one of the Exclude arguments
                                    % so do not continue
                                    go_on = 0;
                                    fprintf('Excluding %s\n',ffname);
                                    % display('In exclude list')
                                    bExclude = 1;
                                    break;
                                end  % if(isempty(strfind(ffname,Args.Exclude{kk})))
                            end  % for kk = 1:length(Args.Exclude)
                            if(bExclude == 0)
                                % means this directory is not in the Exclude list
                                if nlevel>=nLevelObject+1
                                    go_on = 1;
                                end
                            end  % if(bExclude == 0)
                        end  % if(iscell(Args.Exclude))
                    end  % if( (isempty(Args.Include)) && (isempty(Args.Exclude)) )
                    
                    if(go_on)
                        cd (item_name)
                        % check if there are any markers that indicate we should skip this directory
                        % need to convert type to one level down
                        currLevelNum = nlevel - 1;
                        currLevelName = levelConvert('levelNo',currLevelNum);
                        if(~checkMarkers(obj,Args.RedoValue,currLevelName))
                            fprintf(['Processing  Level %i  ' currLevelName ' ' item_name '\n'], currLevelNum);
                            % check the present level, to decide if we need to
                            % continue to call ProcessLevel
                            if(isempty(Args.nptLevelCmd) ||...
                                    (~isempty(Args.nptLevelCmd) && currLevelNum~=levelConvert('levelName',Args.nptLevelCmd{1})))
                                if isempty(Args.AnalysisLevel)
                                    if nlevel > nLevelObject+1
                                        cmdstr = 'Level';
                                    elseif nlevel == nLevelObject+1
                                        cmdstr = 'feval';
                                    end
                                else%if(isempty(Args.AnalysisLevel))
                                    if strcmp(Args.AnalysisLevel,'Single')
                                        if nlevel > nLevelObject+1
                                            cmdstr = 'Level';
                                        elseif nlevel == nLevelObject+1
                                            cmdstr = 'feval';
                                        end
                                    else
                                        if nlevel == nLevelObject+3
                                            cmdstr = 'Combination';
                                        elseif nlevel > nLevelObject+1
                                            cmdstr = 'Level';
                                        elseif nlevel == nLevelObject+1
                                            cmdstr = 'feval';
                                        end
                                    end
                                end%(isempty(Args.AnalysisLevel))
                            elseif (~isempty(Args.nptLevelCmd) && currLevelNum==levelConvert('levelName',Args.nptLevelCmd{1}))
                                eval(Args.nptLevelCmd{2});
                                cmdstr = 'other';
                            end %if(isempty(Args.nptLevelCmd))
                            
                            
                            switch cmdstr
                                case 'Level'
                                    if(position==1)
                                        if(varinNum>2)
                                            [p,pdata] = ProcessLevel(eval(class(obj)),'Levels',levelConvert('levelNo',currLevelNum),varargin2{position+2:varinNum});
                                        else
                                            [p,pdata] = ProcessLevel(eval(class(obj)),'Levels',levelConvert('levelNo',currLevelNum));
                                        end
                                    elseif(position==varinNum-2)
                                        [p,pdata] = ProcessLevel(eval(class(obj)),'Levels',levelConvert('levelNo',currLevelNum),varargin2{1:varinNum-2});
                                    else
                                        [p,pdata] = ProcessLevel(eval(class(obj)),'Levels',levelConvert('levelNo',currLevelNum),varargin2{1:position-1},varargin2{position+2:varinNum});
                                    end
                                    robj = plus(robj,p,varargin2{:});
                                    if(~isempty(Args.DataPlusCmd))
                                        eval(Args.DataPlusCmd);
                                    end
                                case 'Combination'
                                    if(position==1)
                                        if(varinNum>2)
                                            [p,pdata] = ProcessCombination(obj,'Levels',levelConvert('levelNo',currLevelNum),varargin2{position+2:varinNum});
                                        else
                                            [p,pdata] = ProcessCombination(obj,'Levels',levelConvert('levelNo',currLevelNum));
                                        end
                                    elseif(position==varinNum-2)
                                        [p,pdata] = ProcessCombination(obj,'Levels',levelConvert('levelNo',currLevelNum),varargin2{1:varinNum-2});
                                    else
                                        [p,pdata] = ProcessCombination(obj,'Levels',levelConvert('levelNo',currLevelNum),varargin2{1:position-1},varargin2{position+2:varinNum});
                                    end
                                    robj = plus(robj,p,varargin2{:});
                                    if(~isempty(Args.DataPlusCmd))
                                        eval(Args.DataPlusCmd);
                                    end
                                case 'feval'
                                    if(isempty(Args.nptLevelCmd))
                                        if(position==1)
                                            if(varinNum>2)
                                                p = feval(class(obj), 'auto', varargin2{:});
                                            else
                                                p = feval(class(obj), 'auto');
                                            end
                                        elseif(position==varinNum-2)
                                            p = feval(class(obj), 'auto', varargin2{1:varinNum-2});
                                        else
                                            p = feval(class(obj), 'auto', varargin2{1:position-1},varargin2{position+2:varinNum});
                                        end
                                        robj = plus(robj,p,varargin2{:});
                                    else
                                        eval(Args.nptLevelCmd{2});
                                    end
                                    if(~isempty(Args.DataPlusCmd))
                                        eval(Args.DataPlusCmd);
                                    end
                                case 'other'
                                    % if(~isempty(Args.DataPlusCmd))
                                    % eval(Args.DataPlusCmd);
                                    % end
                            end % switch cmdstr
                            % create marker if necessary
                            createProcessedMarker(obj,currLevelName);
                            cd ..
                        else
                            fprintf(['Skipping  Level %i  ' currLevelName ' ' item_name '\n'], currLevelNum);
                            cd ..
                        end % if(~checkMarkers(obj,Args.RedoValue,Args.Levels))
                    end % if(go_on)
                end
            end %if(list(i).isdir)
        end %for i=1:size(list,1)
    elseif (~isempty(Args.nptLevelCmd) && nlevel==levelConvert('levelName',Args.nptLevelCmd{1}))
        eval(Args.nptLevelCmd{2});
    end %if(isempty(Args.nptLevelCmd))
end %if(mark1==0)
