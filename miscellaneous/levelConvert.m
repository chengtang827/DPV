function n = levelConvert(varargin)
% This function is used to do conversion between levels and level names. 
% It reads the configration.txt or configurationDefault.txt for level names
% information.

Args = struct('levelNo','','levelName','');
[Args,varargin2] = getOptArgs(varargin,Args);

b_levelName = {'Cell','Channel','Array','Session','Day','Days'};
cwd = pwd;
dpv_prefdir = getPrefDir;
if(exist(dpv_prefdir,'dir')==7)
    % The preference directory exists
    cd(dpv_prefdir)
    % Check if the user created configuration file is saved in prefdir
    if(ispresent('configuration.txt','file'))
        content = textread('configuration.txt','%s');
        index = find(cell2array(strfind(content,'*'))==1);
        if(index(1)==1)
            a_nptDataDir = '';
        else
            a_nptDataDir = content{1};
        end
        b_levelName = content(index(1)+1:index(2)-1);
    end
end
n = [];
if(~isempty(Args.levelNo))
    n = b_levelName{Args.levelNo};
end
if(~isempty(Args.levelName))
    for i = 1:length(b_levelName)
        if(strcmpi(Args.levelName,b_levelName{i}))
            n = i;
        end
    end
    if(isempty(n))
        n = 0;
    end
end

cd(cwd)