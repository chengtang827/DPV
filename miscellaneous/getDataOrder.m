function [p,varargout] = getDataOrder(varargin)
%getDataOrder Return directory hierarchy information used in the Gray Lab.
%   P = getDataOrder(LEVEL) returns the absolute path to LEVEL from the
%   current directory. These are the recognized values for LEVEL:
%      'days', 'day', 'site', 'session', 'group', 'cluster', 'lfp', 'highpass',
%      'eye', 'eyefilt', 'sort'.
%      e.g. calling getDataOrder('site') from
%      /Data/a1/site02/session03/group0004/cluster01s returns
%      /Data/a1/site02.
%
%   P = getDataOrder(LEVEL,'Relative') returns the relative path to LEVEL.
%      e.g. calling getDataOrder('site','relative') in the above example
%      will return ../../../
%
%   [P,CWD] = getDataOrder(...,'CDNow') changes directory in addition to
%   returning the path. The previous directory is returned in CWD.
%
%   This function only works going upwards because directory splits in
%   downward direction. This function does not check whether the
%   directory actually exists.
%
%   P = getDataOrder(PREFIX) returns the prefix for the specified directory
%   level. These are the recognized PREFIX values and their current return
%   values:
%      'CellPrefix'      'cell'
%      'ChannelPrefix'   'channel'
%      'ArrayPrefix'		 'array'
%      'ComboPrefix'     'combinations'
%      'SessionPrefix'   'session'
%      'DayPrefix'       'day'
%      'DaysPrefix'      'days'
%   Note that the first argument is ignored so it can be anything.
%
%   P = getDataOrder('ShortName') returns the abbreviated name to the
%   current directory so if we are in:
%      /Data/a1/site02/session03/group0004/cluster01s,
%   P is a1s2n3g4c1s. This can be used to shorten strings in the title of
%   plots.
%
%   P = getDataOrder('GetClusterDirs') returns the full paths to the
%   directories which make up a combination directory.
%      e.g. calling getDataOrder('GetClusterDirs') from
%      /Data/a1/site02/session03/combinations/g2c1sg4c1s will return the
%      following cell array:
%      P{1} = '/Data/a1/site02/session03/group0002/cluster01s';
%      P{2} = '/Data/a1/site02/session03/group0004/cluster01s';
%   This can be used by objects that are instantiated in the combinations
%   directory to figure out the individual component cluster directories.
%   Note that the first argument is ignored so that it can be anything.
%
%   P = getDataOrder(...,'DirString',DIRSTRING) uses DIRSTRING instead of
%   the current directory.
%      e.g. getDataOrder('days','DirString','/Data/disco/080204/site01')
%      returns /Data/disco.

%   (not implemented yet)
%   P = getDataOrder('ShortDirName',DIRECTORIES) returns the abbreviated name
%   for combination directories.

Args = struct('Level','','Array',0,'Sort',0,'HighPass',0,'Eye',0, ...
	'EyeFilt',0,'Lfp',0,'Session',0,'Day',0,'Days',0,...
    'LevelPrefix','','CellPrefix',0,'ChannelPrefix',0,'Channel',0,...
	'SessionPrefix',0,'ArrayPrefix',0,'DayPrefix',0,'DaysPrefix',0,...
    'ComboPrefix',0,'GetDirs',0,'GetClusterDirs',0,...
    'Relative',0,'ShortName',0,'CDNow',0,'DirString','','GetPathUpto','');
Args.flags = {'Channel','Array','Sort','HighPass','Eye','EyeFilt','Lfp', ...
	'Session','Site','Day','Days','Relative','CellPrefix','ChannelPrefix', ...
	'ComboPrefix','SessionPrefix','ArrayPrefix','DayPrefix','DaysPrefix', ...
	'CDNow','GetDirs','GetClusterDirs','ShortName'};
Args = getOptArgs(varargin,Args);

% make sure varargout is returned
varargout{1} = '';

% *************************************************************************
% Default level information
nptDataDir = '';
levelName = lower({'Cluster','Channel','Array','Session','Day','Days'});
levelAbbrs = 'cgns';
namePattern = {'cell00','channel0000','array00','session00','site00'};
levelEqualName = {'Group/Sort/HighPass/Eye/EyeFilt/Lfp'};

cwd = pwd;
dpv_prefdir = getPrefDir();
if(exist(dpv_prefdir,'dir')==7)
    % The preference directory exists
    cd(dpv_prefdir)
    % Check if the user created configuration file is saved in prefdir
    if(ispresent('configuration.txt','file'))
        % Read Configuration.txt file for level information
        content = textread('configuration.txt','%s');
    end
end
cd(cwd)
index = find(cell2array(strfind(content,'*'))==1);
% Assign information to variables
if(index(1)==1)
    nptDataDir = '';
else
    nptDataDir = content{1};
end
levelName = lower(content(index(1)+1:index(2)-1));
if(index(2)+1== index(3))
    levelAbbrs = '';
else
    levelAbbrs = content{index(2)+1};
end
namePattern = content(index(3)+1:index(4)-1);
levelEqualName = content(index(4)+1:index(5)-1);
%**************************************************************************

% define constants
comboDName = 'combinations';
levell = length(levelName);
fschar = '/';
pcfschar = '\';
searchstr = ['%[^' fschar ']' fschar];
% number of fileseps to subtract from the cluster directory to get to the
% beginning of the highest level directory (i.e. data directory)
nfilesep = length(levelName)-2;
for i = levell:-1:1
    levels{i,1} = levelName{i};
    levels{i,2} = i;
end

if(isempty(Args.DirString))
    pwDir = pwd;
else
    pwDir = Args.DirString;
end

% return directory name prefixes so that this function can be the sole
% repository of directory name information, which makes it easy to make
% changes if we ever change the directory names
if(Args.Channel)
    if(levelConvert('LevelName','Channel'))
        Args.Level = 'channel';
    end
elseif(Args.Array)
    if(levelConvert('LevelName','Array'))
        Args.Level = 'array';
    end
elseif(Args.Sort)
    if(levelConvert('LevelName','Channel'))
        Args.Level = 'Sort';
    end
elseif(Args.HighPass)
    if(levelConvert('LevelName','Channel'))
        Args.Level = 'HighPass';
    end
elseif(Args.Eye)
    if(levelConvert('LevelName','Channel'))
        Args.Level = 'Eye';
    end
elseif(Args.EyeFilt)
    if(levelConvert('LevelName','Channel'))
        Args.Level = 'EyeFilt';
    end
elseif(Args.Lfp)
    if(levelConvert('LevelName','Channel'))
        Args.Level = 'Lfp';
    end
elseif(Args.Session)
    if(levelConvert('LevelName','Session'))
        Args.Level = 'Session';
    end
elseif(Args.Day)
    if(levelConvert('LevelName','Day'))
        Args.Level = 'Day';
    end
elseif(Args.Days)
    if(levelConvert('LevelName','Days'))
        Args.Level = 'Days';
    end
end

if(Args.CellPrefix)
    if(levelConvert('LevelName','Cell'))
        Args.LevelPrefix = 'cell';
    end
elseif(Args.ChannelPrefix)
    if(levelConvert('LevelName','Channel'))
        Args.LevelPrefix = 'channel';
    end
elseif(Args.ArrayPrefix)
    if(levelConvert('LevelName','Array'))
        Args.LevelPrefix = 'array';
    end
elseif(Args.SessionPrefix)
    if(levelConvert('LevelName','Session'))
        Args.LevelPrefix = 'session';
    end
elseif(Args.DayPrefix)
    if(levelConvert('LevelName','Day'))
        Args.LevelPrefix = 'day';
    end
elseif(Args.DaysPrefix)
    if(levelConvert('LevelName','Days'))
        Args.LevelPrefix = 'days';
    end
end




if(Args.ComboPrefix)
	p = comboDName;
	return
elseif(~isempty(Args.LevelPrefix))
    p = lower(Args.LevelPrefix);
    return
elseif(Args.ShortName)
	destLevel = pwDir;
	% if on windows, replace \ with / so that strread will work properly
	% otherwise, for some reason, strread returns the entire string instead of
	% parsing it into parts
	% if(strcmp(computer,'PCWIN'))
		if(ischar(destLevel))
			destLevel = strrep(destLevel,pcfschar,fschar);
		end
	% end
    % find indicies corresponding to filesep
    %fi = strfind(destLevel,fschar);
    % cluster directory name looks like:
    % /.../a1/site01/session01/group0002/cluster02s
    % get substring starting from character after 5th last filesep
    %dname = destLevel( (fi(end-nfilesep)+1):end );
		if ~isempty(nptDataDir)
	    dname = strrep(destLevel,[nptDataDir '/'],'');
		else
			dname = destLevel;
		end
    p = [];
    % check if dname contains combinations
    if(isempty(strfind(dname,comboDName)))
				a = split(dname, filesep);
				%remove redundant paorts
				gname = regexprep(a{end}, '[0-9]*',''); %get rid of numbers
				thislevel = levelConvert('levelName',gname);
				a = a((length(a)-(levell - thislevel)):end);
        %for k = 1:(levell-1)
        %    [token, dname] = strtok(dname,'/');
        %j    a{k} = token;
        %end
        for kk = 1:(levell-thislevel+1)
            astr = a{kk};
            astrnumber = str2num(astr(find(astr(:) >= 48 & astr(:) <= 57)));
            if(isempty(astrnumber))
                p = [p astr];
            else
                % Named with digits <><digits>
								gname = regexprep(astr, '[0-9]*','');
                if(strcmpi(gname,levelName(levell-kk+1)))
                    if(length(levelAbbrs)>=levelConvert('levelName',levelName{levell-kk+1}))
                        Abbr = levelAbbrs(levelConvert('levelName',levelName{levell-kk+1}));
                    else
                        Abbr = [];
                    end
                    % With level Abbr
                    if(~isempty(Abbr))
                        p = [p Abbr num2str(str2num(astr(find(astr(:) >= 48 & astr(:) <= 57))))];
                    else % Without level abbr
                        p = [p astr(1:min(find(astr(:) >= 48 & astr(:) <= 57))-1) num2str(str2num(astr(find(astr(:) >= 48 & astr(:) <= 57))))];
                    end
                else % Named without digits
                    p = [p astr(1:min(find(astr(:) >= 48 & astr(:) <= 57))-1) num2str(str2num(astr(find(astr(:) >= 48 & astr(:) <= 57))))];
                end
                if(isempty(str2num(astr(end))))
                    p = [p astr(end)];
                else
                    p = p;
                end
            end
        end
    else
        k = 1;
        [token, dname] = strtok(dname,'/');
        while(~isempty(token))
            a{k} = token;
            [token, dname] = strtok(dname,'/');
            k = k+1;
        end
        for kk = 1:length(a)
            astr = a{kk};
            if(~strcmp(astr,comboDName))
                astrnumber = str2num(astr(find(astr(:) >= 48 & astr(:) <= 57)));
                if(isempty(astrnumber))
                    p = [p astr];
                else
                    if(strcmpi(astr(1:min(find(astr(:) >= 48 & astr(:) <= 57))-1),levelName(levell-kk)))
                        if(length(levelAbbrs)>=levelConvert('levelName',levelName{levell-kk}))
                            Abbr = levelAbbrs(levelConvert('levelName',levelName{levell-kk}));
                        else
                            Abbr = [];
                        end
                        % With level Abbr
                        if(~isempty(Abbr))
                            p = [p Abbr num2str(str2num(astr(find(astr(:) >= 48 & astr(:) <= 57))))];
                        else % Without level abbr
                            p = [p astr(1:min(find(astr(:) >= 48 & astr(:) <= 57))-1) num2str(str2num(astr(find(astr(:) >= 48 & astr(:) <= 57))))];
                        end
                    else
                        p = [p astr(1:min(find(astr(:) >= 48 & astr(:) <= 57))-1) num2str(str2num(astr(find(astr(:) >= 48 & astr(:) <= 57))))];
                    end
                    if(isempty(str2num(astr(end))))
                        p = [p astr(end)];
                    else
                        p = p;
                    end
                end
            else
                p = [p a{kk+1}];
                return
            end
        end
    end
	return
elseif(Args.GetDirs | Args.GetClusterDirs)
	% if on windows, replace \ with / so that strread will work properly
	% otherwise, for some reason, strread returns the entire string instead of
	% parsing it into parts
	% if(strcmp(computer,'PCWIN'))
	pwDir = strrep(pwDir,pcfschar,fschar);
	% end
	% find indicies corresponding to filesep
	fi = strfind(pwDir,fschar);
    pwDir1 = strrep(pwDir,[nptDataDir '/'],'');
	% parse cluster directory names from current directory
	a = strread(pwDir1,'%s ','whitespace',fschar);
	% get the length of a
	al = length(a);
	% check to see if the second to last field is combinations
    if(strcmp(a{al-1},comboDName))
        unitAbbr = levelAbbrs(levell-al+1);
        elementAbbr = levelAbbrs(levell-al);
        if(a{al}(1)==unitAbbr)
            % try to parse last field to get unit and element names
            if(isempty(str2num(a{al}(end)))) % element end with char
                [g,gl] = sscanf(a{al},[unitAbbr '%d' elementAbbr '%d%c']);
                % divide length of g by 3 to figure out how many element directories
                % there are
                elementDs = gl/3;
                if(strfind(num2str(elementDs),'.'))
                    [g,gl] = sscanf(a{al},[unitAbbr '%d%c' elementAbbr '%d%c']);
                    % divide length of g by 4 to figure out how many element directories
                    % there are
                    elementDs = gl/4;
                    % reshape g
                    gr = reshape(g,4,elementDs);
                else
                    % reshape g
                    gr = reshape(g,3,elementDs);
                end
            else % element end with digit
                [g,gl] = sscanf(a{al},[unitAbbr '%d' elementAbbr '%d']);
                % divide length of g by 2 to figure out how many element directories
                % there are
                elementDs = gl/2;
                if(strfind(num2str(elementDs),'.'))
                    [g,gl] = sscanf(a{al},[unitAbbr '%d%c' elementAbbr '%d']);
                    % divide length of g by 3 to figure out how many element directories
                    % there are
                    elementDs = gl/3;
                    % reshape g
                    gr = reshape(g,3,elementDs);
                else
                    % reshape g
                    gr = reshape(g,2,elementDs);
                end
            end
            % pre-allocate memory
            p1 = cell(1,elementDs);
            prefix = pwDir(1:fi(end-1));
            unitDName = levelName{levell-al+1};
            elementDName = levelName{levell-al};
            unitstr = strrep(namePattern{find(cell2array(strfind(namePattern,unitDName))==1)},unitDName,'');
            if(isempty(str2num(unitstr(end)))) % end with char
                unitNo = length(unitstr) - 1;
                unitendchar = '%c';
            else
                unitNo = length(unitstr);
                unitendchar = '';
            end
            elementstr = strrep(namePattern{find(cell2array(strfind(namePattern,elementDName))==1)},elementDName,'');
            if(isempty(str2num(elementstr(end)))) % end with char
                elementNo = length(elementstr) - 1;
                elementendchar = '%c';
            else
                elementNo = length(elementstr);
                elementendchar = '';
            end
            for idx = 1:elementDs
                p1{idx} = sprintf(['%s' unitDName ['%0' num2str(unitNo) 'd' unitendchar '/'] elementDName ['%0' num2str(elementNo) 'd' elementendchar]], ...
                    prefix,gr(:,idx));
            end
            p = {p1{:}};
        elseif(a{al}(1)=='a');
            % try to parse last field to get unit and element names
            if(isempty(str2num(a{al}(end)))) % element end with char
                [g,gl] = sscanf(a{al},['a' unitAbbr '%d' elementAbbr '%d%c']);
                % divide length of g by 3 to figure out how many element directories
                % there are
                elementDs = gl/3;
                if(strfind(num2str(elementDs),'.'))
                    [g,gl] = sscanf(a{al},['a' unitAbbr '%d%c' elementAbbr '%d%c']);
                    % divide length of g by 4 to figure out how many element directories
                    % there are
                    elementDs = gl/4;
                    % reshape g
                    gr = reshape(g,4,elementDs);
                else
                    % reshape g
                    gr = reshape(g,3,elementDs);
                end
            else % element end with digit
                [g,gl] = sscanf(a{al},['a' unitAbbr '%d' elementAbbr '%d']);
                % divide length of g by 2 to figure out how many element directories
                % there are
                elementDs = gl/2;
                if(strfind(num2str(elementDs),'.'))
                    [g,gl] = sscanf(a{al},['a' unitAbbr '%d%c' elementAbbr '%d']);
                    % divide length of g by 3 to figure out how many element directories
                    % there are
                    elementDs = gl/3;
                    % reshape g
                    gr = reshape(g,3,elementDs);
                else
                    % reshape g
                    gr = reshape(g,2,elementDs);
                end
            end
            % pre-allocate memory
            p1 = cell(1,elementDs);
            prefix = pwDir(1:fi(end-1));
            unitDName = levelName{levell-al+1};
            elementDName = levelName{levell-al};
            unitstr = strrep(namePattern{find(cell2array(strfind(namePattern,unitDName))==1)},unitDName,'');
            if(isempty(str2num(unitstr(end)))) % end with char
                unitNo = length(unitstr) - 1;
                unitendchar = '%c';
            else
                unitNo = length(unitstr);
                unitendchar = '';
            end
            elementstr = strrep(namePattern{find(cell2array(strfind(namePattern,elementDName))==1)},elementDName,'');
            if(isempty(str2num(elementstr(end)))) % end with char
                elementNo = length(elementstr) - 1;
                elementendchar = '%c';
            else
                elementNo = length(elementstr);
                elementendchar = '';
            end
            for idx = 1:elementDs
                p1{idx} = sprintf(['%s' unitDName ['%0' num2str(unitNo) 'd' unitendchar '/'] elementDName ['%0' num2str(elementNo) 'd' elementendchar]], ...
                    prefix,gr(:,idx));
            end
            p = {p1{:}};
        elseif(a{al}(1)=='p')
            % try to parse last field to get unit and element names
            if(isempty(str2num(a{al}(end)))) % element end with char
                [g,gl] = sscanf(a{al},['p' unitAbbr '%d' elementAbbr '%d%c' unitAbbr '%d' elementAbbr '%d%c']);
                % divide length of g by 6 to figure out how many element directories
                % there are
                elementDs = gl/6;
                if(strfind(num2str(elementDs),'.'))
                    [g,gl] = sscanf(a{al},['p' unitAbbr '%d%c' elementAbbr '%d%c' unitAbbr '%d%c' elementAbbr '%d%c']);
                    % divide length of g by 8 to figure out how many element directories
                    % there are
                    elementDs = gl/8;
                    % reshape g
                    gr = reshape(g,8,elementDs);
                else
                    % reshape g
                    gr = reshape(g,6,elementDs);
                end
            else % element end with digit
                [g,gl] = sscanf(a{al},['p' unitAbbr '%d' elementAbbr '%d' unitAbbr '%d' elementAbbr '%d']);
                % divide length of g by 4 to figure out how many element directories
                % there are
                elementDs = gl/4;
                if(strfind(num2str(elementDs),'.'))
                    [g,gl] = sscanf(a{al},['p' unitAbbr '%d%c' elementAbbr '%d' unitAbbr '%d%c' elementAbbr '%d']);
                    % divide length of g by 6 to figure out how many element directories
                    % there are
                    elementDs = gl/6;
                    % reshape g
                    gr = reshape(g,6,elementDs);
                else
                    % reshape g
                    gr = reshape(g,4,elementDs);
                end
            end
            % pre-allocate memory
            p1 = cell(1,elementDs);
            prefix = pwDir(1:fi(end-1));
            unitDName = levelName{levell-al+1};
            elementDName = levelName{levell-al};
            unitstr = strrep(namePattern{find(cell2array(strfind(namePattern,unitDName))==1)},unitDName,'');
            if(isempty(str2num(unitstr(end)))) % end with char
                unitendchar = '%c';
            else
                unitendchar = '';
            end
            elementstr = strrep(namePattern{find(cell2array(strfind(namePattern,elementDName))==1)},elementDName,'');
            if(isempty(str2num(elementstr(end)))) % end with char
                elementendchar = '%c';
            else
                elementendchar = '';
            end
            for idx = 1:elementDs
                p1{idx} = sprintf(['%s' unitAbbr ['%01d' unitendchar] elementAbbr ['%01d' elementendchar]...
                    unitAbbr ['%01d' unitendchar] elementAbbr ['%01d' elementendchar]], ...
                    prefix,gr(:,idx));
            end
            p = {p1{:}};
        end
    else
        p = {};
    end
    return
end

destLevel = '';

if(~isempty(Args.Level))
   if(levelConvert('LevelName',Args.Level)) % can find this level in levelName
       destL = levelConvert('LevelName',Args.Level);
   else
       destLevel = lower(Args.Level)
       for aa = 1:length(levelEqualName)
           for bb = 1:levell
               if(strfind(lower(levelEqualName{aa}),levelName{bb})==1)
                   destL = levelConvert('LevelName',levelName{bb});
               end
           end
       end
   end
end

% check if current directory path contains the string combinations
if(~isempty(strfind(lower(pwDir),comboDName)))
    [p,n,e] = nptFileParts(pwDir);
    if(strcmp(lower(n),comboDName))
        [p,n,e] = nptFileParts(p);
        curL='';
        for ii=1:size(levels,1)
            if ~isempty(strfind(lower(n),levels{ii,1}))
                curL  = levels{ii,2} - 1;
            end
        end
    else
        while(~strcmp(lower(n),comboDName))
            [p,n,e] = nptFileParts(p);
        end
        [p,n,e] = nptFileParts(p);
        curL='';
        for ii=1:size(levels,1)
            if ~isempty(strfind(lower(n),levels{ii,1}))
                curL  = levels{ii,2} - 2;
            end
        end
    end
else
    [p,n,e] = fileparts(pwDir);
    curL='';
    for ii=1:size(levels,1)
				%hack to recognize a day, i.e. a directory with only digits
        if (~isempty(strfind(lower(n),levels{ii,1}))) ||...
						(isempty(regexprep(n, '[0-9]*','')) && strcmpi(levels{ii,1},'day'))
            curL  = levels{ii,2};
        end
    end
end
if isempty(curL)
    fprintf('Warning: Could not determine current level.\n');
    fprintf('Leaving current directory unchanged.\n');
    p = pwDir;
    return
end
if(Args.Relative)
    % initialize p with the current directory in case the current directory
    % is the destination directory
    p=['.' filesep];
    for ii=1:(destL-curL)
        p=[p '..' filesep];
    end
    if(~isempty(destLevel))
    	p = fullfile(p,destLevel,'');
    end
else
   p=pwDir;
    for ii=1:(destL-curL)
        p=fileparts(p);
    end
    if(~isempty(destLevel))
    	p = fullfile(p,destLevel,'');
    end
end
if(Args.CDNow)
    % make sure directory exists
    if(isdir(p))
    	cd(p);
    	varargout{1} = pwDir;
    else
        fprintf('Warning: Target directory not present!\n');
    end
end
if(~isempty(Args.GetPathUpto))
    if(strfind(pwDir,lower(Args.GetPathUpto)))
        a = strfind(pwDir,'/');
        p = strrep(pwDir,pwDir(a(find(a>strfind(pwDir,lower(Args.GetPathUpto)))):end),'');
    end
end
