function [p,varargout] = getDataDirs(varargin)
%getDataDirs Return directory hierarchy information used in the Gray Lab.
%   P = getDataDirs(LEVEL) returns the absolute path to LEVEL from the
%   current directory. These are the recognized values for LEVEL: 
%      'days', 'day', 'site', 'session', 'group', 'cluster', 'lfp', 'highpass', 
%      'eye', 'eyefilt', 'sort'.
%      e.g. calling getDataDirs('site') from
%      /Data/a1/site02/session03/group0004/cluster01s returns
%      /Data/a1/site02.
%
%   P = getDataDirs(LEVEL,'Relative') returns the relative path to LEVEL.
%      e.g. calling getDataDirs('site','relative') in the above example
%      will return ../../../
%
%   [P,CWD] = getDataDirs(...,'CDNow') changes directory in addition to
%   returning the path. The previous directory is returned in CWD.
%
%   This function only works going upwards because directory splits in 
%   downward direction. This function does not check whether the 
%   directory actually exists.
%
%   P = getDataDirs(PREFIX) returns the prefix for the specified directory
%   level. These are the recognized PREFIX values and their current return
%   values:
%      'CellPrefix'      'cluster'
%      'GroupPrefix'     'group'
%      'ComboPrefix'     'combinations'
%      'SessionPrefix'   'session'
%      'SitePrefix'      'site'
%      'DayPrefix'       'day'
%      'DaysPrefix'      'days'
%   Note that the first argument is ignored so it can be anything.
%
%   P = getDataDirs('ShortName') returns the abbreviated name to the 
%   current directory so if we are in:
%      /Data/a1/site02/session03/group0004/cluster01s, 
%   P is a1s2n3g4c1s. This can be used to shorten strings in the title of
%   plots.
%
%   P = getDataDirs('GetClusterDirs') returns the full paths to the
%   directories which make up a combination directory.
%      e.g. calling getDataDirs('GetClusterDirs') from
%      /Data/a1/site02/session03/combinations/g2c1sg4c1s will return the
%      following cell array: 
%      P{1} = '/Data/a1/site02/session03/group0002/cluster01s';
%      P{2} = '/Data/a1/site02/session03/group0004/cluster01s';
%   This can be used by objects that are instantiated in the combinations
%   directory to figure out the individual component cluster directories.
%   Note that the first argument is ignored so that it can be anything.
%
%   P = getDataDirs(...,'DirString',DIRSTRING) uses DIRSTRING instead of
%   the current directory.
%      e.g. getDataDirs('days','DirString','/Data/disco/080204/site01') 
%      returns /Data/disco.

%   (not implemented yet)
%   P = getDataDirs('ShortDirName',DIRECTORIES) returns the abbreviated name
%   for combination directories. 

Args = struct('Group',0,'Sort',0,'HighPass',0,'Eye',0, ...
	'EyeFilt',0,'Lfp',0,'Session',0,'Site',0,'Day',0,'Days',0, ...
	'Relative',0,'CellPrefix',0,'GroupPrefix',0,'ComboPrefix',0, ...
	'SessionPrefix',0,'SitePrefix',0,'DayPrefix',0,'DaysPrefix',0, ...
	'ShortName',0,'CDNow',0,'GetClusterDirs',0,'DirString','');
Args.flags = {'Group','Sort','HighPass','Eye','EyeFilt','Lfp', ...
	'Session','Site','Day','Days','Relative','CellPrefix','GroupPrefix', ...
	'ComboPrefix','SessionPrefix','SitePrefix','DayPrefix','DaysPrefix', ...
	'CDNow','GetClusterDirs','ShortName'};
Args = getOptArgs(varargin,Args);

% make sure varargout is returned
varargout{1} = '';

% define constants
CLUSTERLEVEL = -2;
GROUPLEVEL = -1;
SORTLEVEL = -1;
HIGHPASSLEVEL = -1;
EYELEVEL = -1;
EYEFILTLEVEL = -1;
LFPLEVEL = -1;
SESSIONLEVEL = 0;
SITELEVEL = 1;
DAYLEVEL = 2;
DAYSLEVEL = 3;

% names for other directories
daysDName = 'days';
dayDName = 'day';
siteDName = 'site';
sessionDName = 'session';
sortDName = 'sort';
highpassDName = 'highpass';
eyeDName = 'eye';
eyefiltDName = 'eyefilt';
lfpDName = 'lfp';
groupDName = 'group';
groupDName2 = 'group00';
clusterDName = 'cluster';
comboDName = 'combinations';

fschar = '/';
pcfschar = '\';
searchstr = ['%[^' fschar ']' fschar];

%dir type and level relative to session directory.
levels = { clusterDName CLUSTERLEVEL; ...
			groupDName GROUPLEVEL; ...
			sortDName SORTLEVEL; ...
			highpassDName HIGHPASSLEVEL; ...
			eyeDName EYELEVEL; ...
			eyefiltDName EYEFILTLEVEL; ...
			lfpDName LFPLEVEL; ...
			sessionDName SESSIONLEVEL; ...
			siteDName SITELEVEL; ...
			dayDName DAYLEVEL; ...
			daysDName DAYSLEVEL};

% abbreviations for other directories
siteAbbr = 's';
sessionAbbr = 'n';
groupAbbr = 'g';
clusterAbbr = 'c';

% define constants
% number of fileseps to subtract from the cluster directory to get to the 
% beginning of the days directory (i.e. data directory)
nfilesep = 4;

if(isempty(Args.DirString))
    pwDir = pwd;
else
    pwDir = Args.DirString;
end

% return directory name prefixes so that this function can be the sole
% repository of directory name information, which makes it easy to make
% changes if we ever change the directory names
if(Args.CellPrefix)
	p = clusterDName;
	return
elseif(Args.GroupPrefix)
	p = groupDName;
	return
elseif(Args.ComboPrefix)
	p = comboDName;
	return
elseif(Args.SessionPrefix)
	p = sessionDName;
	return
elseif(Args.SitePrefix)
	p = siteDName;
	return
elseif(Args.DayPrefix || Args.DaysPrefix)
	p = '';
	return
elseif(Args.ShortName)
	destLevel = pwDir;
	% if on windows, replace \ with / so that strread will work properly
	% otherwise, for some reason, strread returns the entire string instead of
	% parsing it into parts
	% replace Windows file separator character if present so objects saved 
	% on Windows machines will work elsewhere
	% if(strcmp(computer,'PCWIN'))
		if(ischar(destLevel))
			destLevel = strrep(destLevel,pcfschar,fschar);
		end
	% end
    % find indicies corresponding to filesep
    fi = strfind(destLevel,fschar);
    % cluster directory name looks like:
    % /.../a1/site01/session01/group0002/cluster02s
    % get substring starting from character after 5th last filesep
    dname = destLevel( (fi(end-nfilesep)+1):end );
    % check if dname contains combinations
    if(isempty(strfind(dname,comboDName)))
        % use this form instead of just calling
        % strread(dname,'whitespace','/') so we don't have to remove each
        % of the prefixes
		[animal,site,session,group,cluster] = strread(dname, ...
			[searchstr siteDName searchstr sessionDName searchstr groupDName2 searchstr clusterDName '%s']);
		% break up cluster into a number and the character indicating whether 
		% it is sua or mua
		clusterstr = cluster{1};
		% get length of clusterstr
		cll = length(clusterstr);
		clustern = str2num(clusterstr(1:(cll-1)));
		clusteru = clusterstr(cll);
		p = [animal{1} siteAbbr num2str(str2num(site{1})) sessionAbbr num2str(str2num(session{1})) groupAbbr num2str(str2num(group{1})) clusterAbbr num2str(clustern) clusteru];
    else
        [animal,site,session,combo] = strread(dname, ...
            [searchstr siteDName searchstr sessionDName searchstr [comboDName fschar] '%s']);
		p = [animal{1} siteAbbr num2str(str2num(site{1})) sessionAbbr num2str(str2num(session{1})) combo{1}];
    end
	return
elseif(Args.GetClusterDirs)
	% if on windows, replace \ with / so that strread will work properly
	% otherwise, for some reason, strread returns the entire string instead of
	% parsing it into parts
	% replace Windows file separator character if present so objects saved 
	% on Windows machines will work elsewhere
	% if(strcmp(computer,'PCWIN'))
		pwDir = strrep(pwDir,pcfschar,fschar);
	% end
	% find indicies corresponding to filesep
	fi = strfind(pwDir,fschar);
	% parse cluster directory names from current directory
	a = strread(pwDir,'%s ','whitespace',fschar);
	% get the length of a
	al = length(a);
	% check to see if the second to last field is combinations
	if(strcmp(a{al-1},comboDName))
		% try to parse last field to get group and cluster names
		[g,gl] = sscanf(a{al},[groupAbbr '%d' clusterAbbr '%d%c']);
		% divide length of g by 3 to figure out how many cluster directories
		% there are
		clusterDs = gl/3;
		% reshape g
		gr = reshape(g,3,clusterDs);
		% pre-allocate memory
		p1 = cell(1,clusterDs);
		prefix = pwDir(1:fi(end-1));
		for idx = 1:clusterDs
			p1{idx} = sprintf(['%s' groupDName '%04d/' clusterDName '%02d%c'], ...
				prefix,gr(:,idx));
		end
		p = {p1{:}};
	else
		p = {};
	end
    return
end
destLevel = '';
if(Args.Group)
	destL = GROUPLEVEL;
elseif(Args.Sort)
	destLevel = 'sort';
	destL = SESSIONLEVEL;
elseif(Args.HighPass)
	destLevel = 'highpass';
	destL = SESSIONLEVEL;
elseif(Args.Eye)
	destLevel = 'eye';
	destL = SESSIONLEVEL;
elseif(Args.EyeFilt)
	destLevel = 'eyefilt';
	destL = SESSIONLEVEL;
elseif(Args.Lfp)
	destLevel = 'lfp';
	destL = SESSIONLEVEL;
elseif(Args.Session)
	destL = SESSIONLEVEL;
elseif(Args.Site)
	destL = SITELEVEL;
elseif(Args.Day)
	destL = DAYLEVEL;
elseif(Args.Days)
	destL = DAYSLEVEL;
end

% check if current directory path contains the string combinations
if(~isempty(strfind(lower(pwDir),comboDName)))
	[p,n,e] = nptFileParts(pwDir);
	if(strcmp(lower(n),comboDName))
		% we are in the combinations directory so set curL to -1
		curL  = -1;
	else
		% right now there is only one directory level below combinations so
		% if the current directory contains combinations but is not actually
		% the combinations directory, then curL has to be -2
		curL = -2;
	end
else
	[p,n,e] = fileparts(pwDir);
	curL='';
	for ii=1:size(levels,1)
		if ~isempty(strfind(lower(n),levels{ii,1}))
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

%To get from one directory to another we will be forced to go through the
%session level.
if Args.Relative
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