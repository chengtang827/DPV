function f = modifyConfig(varargin)
% This function is used to modify the configuration.txt file after the
% first setup. The users call this function to modify the file
% configuration.txt instead of opening and modifying it directly. 
% 
% Default values in Configuration file is listed below: 
% 
% nptDataDir: ''
%
% Data hierarchy (Levels): Cluster, Group, Session, Site, Day, Days
% 
% Level name abbreviation: c(Cluster), g(Group), n(Session), s(Site) 
% 
% Level name pattern (the way to name the data hierarchy): cluster00s, group0000, session00, site00
% 
% Equivalent level names: Group/Sort/HighPass/Eye/EyeFilt/Lfp
% 
%
% Examples: 
% f = modifyConfig('nptDataDir', 'root_data_directory');
%
% f = modifyConfig('levelNames', {'Cluster','Group','Session','Site','Day','Days'});
% For modifying the level names, please put the names in order, the 
% lowest level as the first one and the highest level as the last one. 
%
% f = modifyConfig('levelAbbr','cgns  ');
% Leave a white space if any level does not have abbreviation
%
% f = modifyConfig('NamePattern',{'cluster00s','group0000','session00','site00'});
% Specify the string pattern the users want to use in data directory
% representation.
%
% f = modifyConfig('EqualName',{'Group/Sort/HighPass/Eye/EyeFilt/Lfp'});
% Specify the usual name of the level in the first place, followed by '/'
% and the equal names.

Args = struct('nptDataDir','','levelNames','','levelAbbr','','NamePattern','','EqualName','');
[Args,varargin2] = getOptArgs(varargin,Args);

cwd = pwd;

cd(prefdir)

if(ispresent('configuration.txt','file'))
    % Read Configuration.txt file
    content = textread('configuration.txt','%s');
    index = find(cell2array(strfind(content,'*'))==1);
    indexlength = length(index);
    % Assign information to variables
    if(index(1)==1)
        a_nptDataDir = '';
    else
        a_nptDataDir = content{1};
    end
    b_levelNames = content(index(1)+1:index(2)-1);
    if(index(2)+1== index(3))
        c_levelAbbr = '';
    else
        c_levelAbbr = content{index(2)+1};
    end
    d_NamePattern = content(index(3)+1:index(4)-1);
    e_levelEqualName = content(index(4)+1:index(5)-1);
    
    % Clear content for modification
    content(:) = [];
    
    % Read new values of variables
    if(~isempty(Args.nptDataDir))
        content{1} = Args.nptDataDir;
    else
        content{1} = a_nptDataDir;
    end
    index1 = length(content);
    content{index1+1} = '*';
    
    if(~isempty(Args.levelNames))
        for i = 1:length(Args.levelNames)
            content{index1+1+i} = Args.levelNames{i};
        end
    else
        for i = 1:length(b_levelNames)
            content{index1+i+1} = b_levelNames{i};
        end
    end
    index2 = length(content);
    content{index2+1} = '*';
    
    if(~isempty(Args.levelAbbr))
        content{index2+2} = Args.levelAbbr;
    else
        content{index2+2} = c_levelAbbr;
    end
    index3 = length(content);
    content{index3+1} = '*';
    
    if(~isempty(Args.NamePattern))
        for i = 1:length(Args.NamePattern)
            content{index3+1+i} = Args.NamePattern{i};
        end
    else
        for i = 1:length(d_NamePattern)
            content{index3+1+i} = d_NamePattern{i};
        end
    end
    index4 = length(content);
    content{index4+1} = '*';
    
    if(~isempty(Args.EqualName))
        for i = 1:length(Args.EqualName)
            content{index4+1+i} = Args.EqualName{i};
        end
    else
        for i = 1:length(e_levelEqualName)
            content{index4+1+i} = e_levelEqualName{i};
        end
    end
    index5 = length(content);
    content{index5+1} = '*';

    fid = fopen('configuration.txt','wt');
    for k = 1:length(content)
        fprintf(fid,'%s\n',content{k});
    end
    fclose(fid);
    f = 1;
else
    warning('There does not exist the configuration.txt file.')
    f = 0;
end

cd(cwd)


