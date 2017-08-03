function [robj,data] = ProcessCombination(obj,varargin)
% This function does combination analysis for any level specified by user. 
%
% Levels:       The name of the highest processed level.
%               e.g.: 'Levels','Days'
%
% AnalysisRelation: Specifies the relationship of cpmbination. 
%               Accept values are: 
%                           'Intra<Level>': give intra-level combination analysis
%                           'Inter<Level>': give inter-level combination analysis
%                           '<Level>': give both intra-level and inter-level analysis 
%               e.g.: 'AnalysisRelation','IntraSession'
%                     'AnalysisRelation','InterHour'
%
% AnalysisLevel:  Specifies the AnalysisLevel property of OBJ.
%               Accepted values are:
%                          'All'             Groups of all intra-level elements for all <Level>s (a)
%                          'Pairs'           Pairs of elements. 
%                          'AllIntra<Level>'   Groups of intra-level elements within one <Level>.
%                          'AllPairs'        Groups of intra-level pairs.(p)
%                                                     
%               Functionality Example: 
%               session12
%               group0001: cluster01s, cluster02s
%               group0002: cluster01s, cluster02s, cluster03s 
%  
%               'All' gives
%               ~/session12/combinations/ag1c1sag1c2sag2c1sag2c2sag2c3s
%               'AllIntraGroup' gives
%               ~/session12/combinations/ag1c1sag1c2s
%               ~/session12/combinations/ag2c1sag2c2sag2c3s
%               'AllPairs' gives
%               ~/session12/combinations/pg1c1sg1c2s
%               ~/session12/combinations/pg2c1sg2c2spg2c1sg2c3spg2c2sg2c3s
%               
%               Usage Example:
%               'AnalysisLevel', 'Pairs'
%               'AnalysisLevel', 'AllIntraCity', group all intra city elements.
%
% DataInit: Specifies the initial value od data. 
%
% nptComboCmd:  Specify the level Performs the following command for each
%               directory in that level.
% 
% DataPlusCmd: Specified if only need to plus the data of the object

Args = struct('RedoValue',0,'Levels','','AnalysisRelation','','AnalysisLevel','',...
    'DataInit',[],'DataPlusCmd','','nptComboCmd','','ArgsOnly',0);
Args.flags = {'ArgsOnly'};
Args.classname = 'ProcessCombination';
[Args,varargin2] = getOptArgs(varargin,Args,'shortcuts',{'Reprocess',{'RedoValue',1}});

nameComboDir = getDataOrder('ComboPrefix');
nameAllDir = 'all';
nlevel = levelConvert('levelName',Args.Levels);
    
checkObjectLevel = 0;
for ii = 1:nlevel
    checkObjectLevela = strcmp(get(obj, 'ObjectLevel'), levelConvert(obj,'levelNo',ii));
    checkObjectLevel = checkObjectLevel + checkObjectLevela;
end
% if user select 'ArgsOnly', return only Args structure for an empty object
if (Args.ArgsOnly)
    if((nlevel-1)>1)
        if (checkObjectLevel)
            [robj, Args.childArgs] = ProcessLevel(obj, 'ArgsOnly', 'Levels', levelConvert(obj,'levelNo',nlevel-1));
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

unitDName = lower(levelConvert('levelNo',nlevel-1));
unitAbbr = lower(unitDName(1));
elementDName = lower(levelConvert('levelNo',nlevel-2));
elementAbbr = lower(elementDName(1));
varinNum = size(varargin, 2);

% find the position of the argunebt Levels
for k = 1:varinNum
    if(iscellstr(varargin(k)))
        findit = strcmp(varargin(k),'Levels');
        if(findit)
            position = k;
        end
    end
end
if(length(Args.AnalysisRelation)>=5)
    if(strcmp(Args.AnalysisRelation(1:5),'Intra'))
        Intra = 1;
        Inter = 0;
        meanStr = Args.AnalysisRelation(6:end);
    elseif(strcmp(Args.AnalysisRelation(1:5),'Inter'))
        Intra = 0;
        Inter = 1;
        meanStr = Args.AnalysisRelation(6:end);
    else
        Intra = 1;
        Inter = 1;
        meanStr = Args.AnalysisRelation;
    end
else
    Intra = 1;
    Inter = 1;
    meanStr = Args.AnalysisRelation;
end

ArgDirName = [meanStr '*'];

robj = obj;
data = Args.DataInit;

% check analysis level
if(strcmpi(Args.AnalysisLevel,'All'))
    % get list of units
    ulist = nptDir(lower(ArgDirName));
    % get number of units
    unum = size(ulist,1);
    % initialize elementnum variable so we can tell if no elements were
    % found, for instance when using the Cells optional input argument
    elementnum = [];
    fprintf(['\tGathering Level %i  ' levelConvert(obj,'levelNo',nlevel-2) ' directories...\n'], nlevel-2);
    for i = 1:unum
        if(ulist(i).isdir)
            if(~strcmp(ulist(i).name,'combinations'))
                % get element directories for each unit
                fprintf(['\t\tProcessing  Level %i  ' nlevel-1 ' ' ulist(i).name '\n'], nlevel-1);
                cd(ulist(i).name);
                if (nlevel-1==levelConvert('levelName',meanStr))
                    % call ProcessLevel itself, with passing new varargin,
                    % i.e., deduct one level
                    if(position==1)
                        if(varinNum>2)
                            [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),varargin{position+2:varinNum},'LevelObject',levelConvert('levelNo',nlevel-2));
                        else
                            [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),'LevelObject',levelConvert('levelNo',nlevel-2));
                        end
                    elseif(position==varinNum-2)
                        [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),varargin{1:varinNum-2},'LevelObject',levelConvert('levelNo',nlevel-2));
                    else
                        [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),varargin{1:position-1},varargin{position+2:varinNum},'LevelObject',levelConvert('levelNo',nlevel-2));
                    end
                end %if (nlevel-1>1)
                elementlist{i} = get(nd,'SessionDirs');
                elementnum(i) = get(nd,'Number');
                cd ..
            end
        end
    end %for i = 1:unum
    % only continue if the elementlist is not empty
    if(~isempty(elementnum))
        % call nptMkDir to create directory if it is not already present
        nptMkDir(nameComboDir);
        % change to combinations directory
        cd(nameComboDir);
        allComboDir = pwd;
        allDirName = [];
        for unit1 = 1:unum
            % initialise the record of each element pair directory
            % do not know the size of it at this stage
            comboDirNameRecord = [];
            % initialize allpairslist variable
            % do this inside the loop over units so that we only
            % group together pairs from the same unit
            alllist = {};
            % get name of unit
            unit1name = ulist(unit1).name;
            % get length of unit1name
            unit1namelength = length(unit1name);
            % get abbreviated number
            unit1number = str2num(unit1name(find(unit1name(:) >= 48 & unit1name(:) <= 57)));
            unlength = length(unit1name(find(unit1name(:) >= 48 & unit1name(:) <= 57)));
            % get number of elements in this unit
            nelements = elementnum(unit1);
            for element1 = 1:nelements
                % get name of first element
                e1 = elementlist{unit1}{element1};
                % get length of e1
                e1length = length(e1);
                % get abbreviated number
                ee = e1(max(strfind(e1,'/'))+1:end);
                e1number = str2num(ee(find(ee(:) >= 48 & ee(:) <= 57)));
                enlength = length(ee(find(ee(:) >= 48 & ee(:) <= 57)));
                if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                    if(e1(e1length)<48 | e1(e1length)>57) % end with char
                        % get portion of comboDirName
                        comboDirName = ['a' unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number) e1(e1length)];
                    else % end with digits
                        % get portion of comboDirName
                        comboDirName = ['a' unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number)];
                    end
                else % end with digits
                    if(e1(e1length)<48 | e1(e1length)>57) % end with char
                        % get portion of comboDirName
                        comboDirName = ['a' unitAbbr num2str(unit1number) elementAbbr num2str(e1number) e1(e1length)];
                    else % end with digits
                        % get portion of comboDirName
                        comboDirName = ['a' unitAbbr num2str(unit1number) elementAbbr num2str(e1number)];
                    end
                end
                allDirName = [allDirName comboDirName];
            end
        end

        nptMkDir(allDirName);
        cd(allDirName);
        % check if we should skip this directory
        if (~checkMarkers(obj,0,'combo'))
            alllist = {alllist{:} [allComboDir filesep allDirName]};
            if(isempty(Args.nptComboCmd))
                % instantiate object inside the combo directory
                pwDir = strrep(pwd,'\','/');
                fi = strfind(pwDir,'/');
                a = strread(pwDir,'%s ','whitespace','/');
                al = length(a);
                if(strcmp(a{al-1},'combinations'))
                    if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                        if(e1(e1length)<48 | e1(e1length)>57) % end with char
                            [g,gl] = sscanf(a{al},['a' unitAbbr '%d%c' elementAbbr '%d%c']);
                            % divide length of g by 4 to figure out how many cluster directories
                            % there are
                            elementDs = gl/4;
                            % reshape g
                            un = reshape(g,4,elementDs);
                        else  % end with digits
                            [g,gl] = sscanf(a{al},['a' unitAbbr '%d%c' elementAbbr '%d']);
                            % divide length of g by 3 to figure out how many cluster directories
                            % there are
                            elementDs = gl/3;
                            % reshape g
                            un = reshape(g,3,elementDs);
                        end
                    else % end with digits
                        if(e1(e1length)<48 | e1(e1length)>57) % end with char
                            [g,gl] = sscanf(a{al},['a' unitAbbr '%d' elementAbbr '%d%c']);
                            % divide length of g by 3 to figure out how many cluster directories
                            % there are
                            elementDs = gl/3;
                            % reshape g
                            un = reshape(g,3,elementDs);
                        else  % end with digits
                            [g,gl] = sscanf(a{al},['a' unitAbbr '%d' elementAbbr '%d']);
                            % divide length of g by 2 to figure out how many cluster directories
                            % there are
                            elementDs = gl/2;
                            % reshape g
                            un = reshape(g,2,elementDs);
                        end
                    end
                    % pre-allocate memory
                    p1 = cell(1,elementDs);
                    prefix = pwDir(1:fi(end-1));
                    for idx = 1:elementDs
                        if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                            if(e1(e1length)<48 | e1(e1length)>57)
                                p1{idx} = sprintf(['%s' unitDName ['%0' num2str(unlength) 'd%c/'] elementDName ['%0' num2str(enlength) 'd%c']], ...
                                    prefix,un(:,idx));
                            else
                                p1{idx} = sprintf(['%s' unitDName ['%0' num2str(unlength) 'd%c/'] elementDName ['%0' num2str(enlength) 'd']], ...
                                    prefix,un(:,idx));
                            end
                        else % end with digits
                            if(e1(e1length)<48 | e1(e1length)>57)
                                p1{idx} = sprintf(['%s' unitDName ['%0' num2str(unlength) 'd/'] elementDName ['%0' num2str(enlength) 'd%c']], ...
                                    prefix,un(:,idx));
                            else
                                p1{idx} = sprintf(['%s' unitDName ['%0' num2str(unlength) 'd/'] elementDName ['%0' num2str(enlength) 'd']], ...
                                    prefix,un(:,idx));
                            end
                        end
                    end
                    alllist1 = {p1{:}};
                else
                    alllist1 = {};
                end
                p = feval(class(obj),'auto','ClusterDirs', alllist1, varargin2{:},'CellName',levelConvert('levelNo',nlevel-2));
                robj = plus(robj,p,varargin2{:});
                if(~isempty(Args.DataPlusCmd))
                    eval(Args.DataPlusCmd);
                end
            else
                % execute nptComboCmd
                eval(Args.nptComboCmd);
            end
        end
        cd ..
        cd ..
    end
else % if(strcmpi(Args.AnalysisLevel,'All'))
    % get list of units
    ulist = nptDir(lower(ArgDirName));
    % get number of units
    unum = size(ulist,1);
    % initialize clusternum variable so we can tell if no clusters were
    % found, for instance when using the Cells optional input argument
    elementnum = [];
    fprintf(['\tGathering Level %i  ' levelConvert(obj,'levelNo',nlevel-2) ' directories...\n'], nlevel-2);
    for i = 1:unum
        if(ulist(i).isdir)
            if(~strcmp(ulist(i).name,'combinations'))
                % get element directories for each unit
                fprintf(['\t\tProcessing  Level %i  ' nlevel-1 ' ' ulist(i).name '\n'], nlevel-1);
                cd(ulist(i).name);
                if (nlevel-1==levelConvert('levelName',meanStr))
                    % call ProcessLevel itself, with passing new varargin,
                    % i.e., deduct one level
                    if(position==1)
                        if(varinNum>2)
                            [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),varargin{position+2:varinNum},'LevelObject',levelConvert('levelNo',nlevel-2));
                        else
                            [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),'LevelObject',levelConvert('levelNo',nlevel-2));
                        end
                    elseif(position==varinNum-2)
                        [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),varargin{1:varinNum-2},'LevelObject',levelConvert('levelNo',nlevel-2));
                    else
                        [nd,pdata] = ProcessLevel(nptdata,'Levels',levelConvert(obj,'levelNo',nlevel-1),varargin{1:position-1},varargin{position+2:varinNum},'LevelObject',levelConvert('levelNo',nlevel-2));
                    end
                end %if (nlevel-1>1)
                elementlist{i} = get(nd,'SessionDirs');
                elementnum(i) = get(nd,'Number');
                cd ..
            end %(~strcmp(ulist(i).name,'combinations'))
        end
    end %for i = 1:unum
    % only continue if the elementlist is not empty
    if(~isempty(elementnum))
        % call nptMkDir to create directory if it is not already present
        nptMkDir(nameComboDir);
        % change to combinations directory
        cd(nameComboDir);
        % save the current directory so that the allpairs option can grab
        % the correct absolute path
        allpairsComboDir = pwd;

        if(strcmpi(Args.AnalysisLevel,'Pairs') || strcmpi(Args.AnalysisLevel,'AllPairs'))
            %
            % Analysis of element Pairs

            if(Intra)
                % loop through intra-unit combinations
                for unit1 = 1:unum
                    % initialise the record of each element pair directory
                    % do not know the size of it at this stage
                    comboDirNameRecord = [];
                    % initialize allpairslist variable
                    % do this inside the loop over units so that we only
                    % group together pairs from the same unit
                    allpairslist = {};
                    % get name of unit
                    unit1name = ulist(unit1).name;
                    % get length of unit1name
                    unit1namelength = length(unit1name);
                    % get abbreviated number
                    unit1number = str2num(unit1name(find(unit1name(:) >= 48 & unit1name(:) <= 57)));
                    % get number of elements in this unit
                    nelements = elementnum(unit1);
                    for element1 = 1:nelements
                        % get name of first element
                        e1 = elementlist{unit1}{element1};
                        % get length of e1
                        e1length = length(e1);
                        % get abbreviated number
                        ee1 = e1(max(strfind(e1,'/'))+1:end);
                        e1number = str2num(ee1(find(ee1(:) >= 48 & ee1(:) <= 57)));
                        if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                            if(e1(e1length)<48 | e1(e1length)>57)% end with char
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number) e1(e1length)];
                            else % end with digits
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number)];
                            end
                        else % end with digits
                            if(e1(e1length)<48 | e1(e1length)>57)% end with char
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) elementAbbr num2str(e1number) e1(e1length)];
                            else % end with digits
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) elementAbbr num2str(e1number)];
                            end
                        end
                        recordFlag = 0;
                        for element2 = (element1+1):nelements
                            recordFlag = 1;
                            % get name of second element
                            e2 = elementlist{unit1}{element2};
                            % get length of e2
                            e2length = length(e2);
                            % get abbreviated number
                            ee2 = e2(max(strfind(e2,'/'))+1:end);
                            e2number = str2num(ee2(find(ee2(:) >= 48 & ee2(:) <= 57)));
                            if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                                if(e2(e2length)<48 | e2(e2length)>57)% end with char
                                    % get directory name for this pair
                                    comboDirName = [c1comboName unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e2number) e2(e2length)];
                                else % end with digits
                                    % get directory name for this pair
                                    comboDirName = [c1comboName unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e2number)];
                                end
                            else % end with digits
                                if(e2(e2length)<48 | e2(e2length)>57)% end with char
                                    % get directory name for this pair
                                    comboDirName = [c1comboName unitAbbr num2str(unit1number) elementAbbr num2str(e2number) e2(e2length)];
                                else % end with digits
                                    % get directory name for this pair
                                    comboDirName = [c1comboName unitAbbr num2str(unit1number) elementAbbr num2str(e2number)];
                                end
                            end
                            fprintf('\t\t\tProcessing pair %s\n',comboDirName);
                            % call nptMkDir to create directory if it is not already
                            % present
                            nptMkDir(comboDirName);
                            cd(comboDirName);
                            % check if we should skip this directory
                            if (~checkMarkers(obj,0,'combo'))
                                if(strcmpi(Args.AnalysisLevel,'AllPairs'))
                                    % add this combo directory to the list
                                    % do this after checkMarkers so that we
                                    % honor skip.txt if it is present
                                    % inside a pair directory
                                    allpairslist = {allpairslist{:} [allpairsComboDir filesep comboDirName]};
                                else
                                    if(isempty(Args.nptComboCmd))
                                        % instantiate object inside the combo directory
                                        p = feval(class(obj),'auto','ClusterDirs',{elementlist{unit1}{element1}, ...
                                            elementlist{unit1}{element2}},varargin2{:},'CellName',levelConvert('levelNo',nlevel-2));
                                        robj = plus(robj,p,varargin2{:});
                                        if(~isempty(Args.DataPlusCmd))
                                            eval(Args.DataPlusCmd);
                                        end
                                    else
                                        % execute nptComboCmd
                                        eval(Args.nptComboCmd);
                                    end
                                end
                            end
                            cd ..

                            comboDirNameRecord = [comboDirNameRecord 'p' comboDirName];
                        end % for element2 = (element1+1):nelements
                    end % end for element1 = 1:nelements
                    if(strcmpi(Args.AnalysisLevel,'AllPairs'))
                        % don't create directory yet since it is not clear
                        % what form it should take. We won't really need
                        % the directory anyway for now since we are just
                        % using this option for display purposes
                        % create directory representing the group of pairs

                        % put the record of all comboDirName s into
                        % allpairsDirName
                        allpairslist = {};
                        if(~isempty(comboDirNameRecord))
                            allpairsDirName = comboDirNameRecord;
                            allpairslist = {allpairslist{:} [allpairsComboDir filesep allpairsDirName]};
                            nptMkDir(allpairsDirName);
                            cd(allpairsDirName);
                            go_on = 1;
                            cdFlag = 1;
                        else
                            go_on = 0;
                            cdFlag = 0;
                        end

                        % check if we should skip this directory
                        if (~checkMarkers(obj,0,'combo'))
                            if(isempty(Args.nptComboCmd))
                                % instantiate object inside the loop over
                                % unit so pairs are separated according
                                % to their units
                                pwDir = strrep(pwd,'\','/');
                                fi = strfind(pwDir,'/');
                                a = strread(pwDir,'%s ','whitespace','/');
                                al = length(a);
                                if(strcmp(a{al-1},'combinations'))
                                    if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                                        if(e1(e1length)<48 | e1(e1length)>57)
                                            [g,gl] = sscanf(a{al},['p' unitAbbr '%d%c' elementAbbr '%d%c' unitAbbr '%d%c' elementAbbr '%d%c']);
                                            % divide length of g by 8 to figure out how many cluster directories
                                            % there are
                                            elementDs = gl/8;
                                            % reshape g
                                            un = reshape(g,8,elementDs);
                                        else % end with digits
                                            [g,gl] = sscanf(a{al},['p' unitAbbr '%d%c' elementAbbr '%d' unitAbbr '%d%c' elementAbbr '%d']);
                                            % divide length of g by 7 to figure out how many cluster directories
                                            % there are
                                            elementDs = gl/7;
                                            % reshape g
                                            un = reshape(g,7,elementDs);
                                        end
                                    else % end with digits
                                        if(e1(e1length)<48 | e1(e1length)>57)
                                            [g,gl] = sscanf(a{al},['p' unitAbbr '%d' elementAbbr '%d%c' unitAbbr '%d' elementAbbr '%d%c']);
                                            % divide length of g by 6 to figure out how many cluster directories
                                            % there are
                                            elementDs = gl/6;
                                            % reshape g
                                            un = reshape(g,6,elementDs);
                                        else % end with digits
                                            [g,gl] = sscanf(a{al},['p' unitAbbr '%d' elementAbbr '%d' unitAbbr '%d' elementAbbr '%d']);
                                            % divide length of g by 4 to figure out how many cluster directories
                                            % there are
                                            elementDs = gl/4;
                                            % reshape g
                                            un = reshape(g,4,elementDs);
                                        end
                                    end
                                    % pre-allocate memory
                                    p1 = cell(1,elementDs);
                                    prefix = [pwDir(1:fi(end-1)) 'combinations/'];
                                    for idx = 1:elementDs
                                        if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                                            if(e1(e1length)<48 | e1(e1length)>57) % end with char
                                                p1{idx} = sprintf(['%s' unitAbbr '%01d%c' elementAbbr '%01d%c' unitAbbr '%01d%c' elementAbbr '%01d%c'], ...
                                                    prefix,un(:,idx));
                                            else % end with digits
                                                p1{idx} = sprintf(['%s' unitAbbr '%01d%c' elementAbbr '%01d' unitAbbr '%01d%c' elementAbbr '%01d'], ...
                                                    prefix,un(:,idx));
                                            end
                                        else % end with digits
                                            if(e1(e1length)<48 | e1(e1length)>57) % end with char
                                                p1{idx} = sprintf(['%s' unitAbbr '%01d' elementAbbr '%01d%c' unitAbbr '%01d' elementAbbr '%01d%c'], ...
                                                    prefix,un(:,idx));
                                            else % end with digits
                                                p1{idx} = sprintf(['%s' unitAbbr '%01d' elementAbbr '%01d' unitAbbr '%01d' elementAbbr '%01d'], ...
                                                    prefix,un(:,idx));
                                            end
                                        end
                                    end
                                    allpairslist1 = {p1{:}};
                                else
                                    allpairslist1 = {};
                                end
                                if(go_on)
                                    p = feval(class(obj),'auto','ClusterDirs',allpairslist1,varargin2{:},'CellName',levelConvert('levelNo',nlevel-2));
                                else
                                    p = feval(class(obj),'ArgsOnly');
                                end
                                robj = plus(robj,p,varargin2{:});                                 
                                if(~isempty(Args.DataPlusCmd))
                                    eval(Args.DataPlusCmd);
                                end
                            else
                                % execute nptComboCmd
                                eval(Args.nptComboCmd);
                            end
                        end %if(~checkMarkers(obj,0,'combo'))

                        if(cdFlag==1)
                            cd ..
                        end
                    end% if (strcmpi(Args.AnalysisLevel,'AllPairs'))
                end % for unit1 = 1:unum
            end % if(Intra)

            if(Inter)
                % loop through inter-<level> combinations
                for unit1 = 1:unum
                    % get name of unit1
                    unit1name = ulist(unit1).name;
                    % get length of unitname
                    unit1namelength = length(unit1name);
                    % get abbreviated number
                    unit1number = str2num(unit1name(find(unit1name(:) >= 48 & unit1name(:) <= 57)));
                    % get number of elements in this unit
                    n1elements = elementnum(unit1);
                    for element1 = 1:n1elements
                        % get name of first element
                        e1 = elementlist{unit1}{element1};
                        % get length of e1
                        e1length = length(e1);
                        % get abbreviated number
                        ee1 = e1(max(strfind(e1,'/'))+1:end);
                        e1number = str2num(ee1(find(ee1(:) >= 48 & ee1(:) <= 57)));
                        if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                            if(e1(e1length)<48 | e1(e1length)>57) % end with char
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number) e1(e1length)];
                            else % end with digits
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number)];
                            end
                        else % end with digits
                            if(e1(e1length)<48 | e1(e1length)>57) % end with char
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) elementAbbr num2str(e1number) e1(e1length)];
                            else % end with digits
                                % get portion of comboDirName
                                c1comboName = [unitAbbr num2str(unit1number) elementAbbr num2str(e1number)];
                            end
                        end
                        for unit2 = (unit1+1):unum
                            % get name of unit
                            unit2name = ulist(unit2).name;
                            % get length of unitname
                            unit2namelength = length(unit2name);
                            % get abbreviated number
                            unit2number = str2num(unit2name(find(unit2name(:) >= 48 & unit2name(:) <= 57)));
                            % get number of elements in this unit
                            n2elements = elementnum(unit2);
                            for element2 = 1:n2elements
                                % get name of second element
                                e2 = elementlist{unit2}{element2};
                                % get length of e2
                                e2length = length(e2);
                                % get abbreviated number
                                ee2 = e2(max(strfind(e2,'/'))+1:end);
                                e2number = str2num(ee2(find(ee2(:) >= 48 & ee2(:) <= 57)));
                                if(unit2name(unit2namelength)<48 | unit2name(unit2namelength)>57) % end with char
                                    if(e2(e2length)<48 | e2(e2length)>57) % end with char
                                        % get directory name for this pair
                                        comboDirName = [c1comboName unitAbbr num2str(unit2number) unit2name(unit2namelength) elementAbbr num2str(e2number) e2(e2length)];
                                    else % end with digits
                                        % get directory name for this pair
                                        comboDirName = [c1comboName unitAbbr num2str(unit2number) unit2name(unit2namelength) elementAbbr num2str(e2number)];
                                    end
                                else % end with digits
                                    if(e2(e2length)<48 | e2(e2length)>57) % end with char
                                        % get directory name for this pair
                                        comboDirName = [c1comboName unitAbbr num2str(unit2number) elementAbbr num2str(e2number) e2(e2length)];
                                    else % end with digits
                                        % get directory name for this pair
                                        comboDirName = [c1comboName unitAbbr num2str(unit2number) elementAbbr num2str(e2number)];
                                    end
                                end
                                fprintf('\t\t\tProcessing cell pair %s\n',comboDirName);
                                % call nptMkDir to create directory if it is not already
                                % present
                                nptMkDir(comboDirName);
                                cd(comboDirName);
                                % check if we should skip this directory
                                if (~checkMarkers(obj,0,'combo'))
                                    if(isempty(Args.nptComboCmd))
                                        % instantiate object inside the combo directory
                                        p = feval(class(obj),'auto','ClusterDirs',{elementlist{unit1}{element1}, ...
                                            elementlist{unit2}{element2}},varargin2{:},'CellName',levelConvert('levelNo',nlevel-2));
                                        robj = plus(robj,p,varargin2{:});
                                        if(~isempty(Args.DataPlusCmd))
                                            eval(Args.DataPlusCmd);
                                        end
                                    else
                                        % execute nptComboCmd
                                        eval(Args.nptComboCmd);
                                    end
                                end
                                cd ..
                            end % for element2 = 1:n2elements
                        end % for unit2 = (unit1+1):unum
                    end % for element1 = 1:n1elements
                end % for unit1 = 1:unum
            end % if(Inter)
        elseif(strcmpi(Args.AnalysisLevel(1:8),'AllIntra')) % (strcmpi(Args.AnalysisLevel,'Pairs') || strcmpi(Args.AnalysisLevel,'AllPairs'))
            %
            % Analysis of all intra<level> elements
            %
            % loop through intra-<level> combinations
            for unit1 = 1:unum
                % get number of elements in this unit
                nelements = elementnum(unit1);
                % only continue if there is more than 1 element
                if(nelements>1)
                    % get name of unit
                    unit1name = ulist(unit1).name;
                    % get length of unit1name
                    unit1namelength = length(unit1name);
                    % get abbreviated number
                    unit1number = str2num(unit1name(find(unit1name(:) >= 48 & unit1name(:) <= 57)));
                    % get directory name for this unit
                    comboUnitupName = [];
                    % inside one unit, find all elements' names
                    for element1 = 1:nelements
                        % get name of first element
                        e1 = elementlist{unit1}{element1};
                        % get length of e1
                        e1length = length(e1);
                        % get abbreviated number
                        ee1 = e1(max(strfind(e1,'/'))+1:end);
                        e1number = str2num(ee1(find(ee1(:) >= 48 & ee1(:) <= 57)));
                        if(unit1name(unit1namelength)<48 | unit1name(unit1namelength)>57) % end with char
                            if(e1(e1length)<48 | e1(e1length)>57) % end with char
                                % get portion of comboDirName
                                comboUnitupName = [comboUnitupName unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number) e1(e1length)];
                            else % end with digits
                                % get portion of comboDirName
                                comboUnitupName = [comboUnitupName unitAbbr num2str(unit1number) unit1name(unit1namelength) elementAbbr num2str(e1number)];
                            end
                        else
                            if(e1(e1length)<48 | e1(e1length)>57) % end with char
                                % get portion of comboDirName
                                comboUnitupName = [comboUnitupName unitAbbr num2str(unit1number) elementAbbr num2str(e1number) e1(e1length)];
                            else % end with digits
                                % get portion of comboDirName
                                comboUnitupName = [comboUnitupName unitAbbr num2str(unit1number) elementAbbr num2str(e1number)];
                            end
                        end
                    end

                    % call nptMkDir to create directory if it is not already
                    % present
                    nptMkDir(comboUnitupName);
                    cd(comboUnitupName);
                    % check if we should skip this directory
                    if (~checkMarkers(obj,0,'combo'))
                        if(isempty(Args.nptComboCmd))
                            % instantiate object inside the combo directory
                            p = feval(class(obj),'auto','ClusterDirs',{elementlist{unit1}{:}},varargin2{:},'CellName',levelConvert('levelNo',nlevel-2));
                            robj = plus(robj,p,varargin2{:});
                            if(~isempty(Args.DataPlusCmd))
                                eval(Args.DataPlusCmd);
                            end
                        else
                            % execute nptComboCmd
                            eval(Args.nptComboCmd);
                        end
                    end
                    cd ..
                end
            end
        end % if(strcmpi(Args.AnalysisLevel,'Pairs'))

        % return to parent directory of nameComboDir
        cd ..
    end % if(~isempty(elementnum))
end % if(strcmpi(Args.AnalysisLevel,'All'))


