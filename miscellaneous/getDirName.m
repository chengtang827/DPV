function r = getDirName(nlevel)

% Default level information
nptDataDir = '';
levelName = lower({'Cluster','Group','Session','Site','Day','Days'});
levelAbbrs = 'cgns';
namePattern = {'cluster00s','group0000','session00','site00'};
levelEqualName = {'Group/Sort/HighPass/Eye/EyeFilt/Lfp'};

cwd = pwd;
if(exist(prefdir,'dir')==7)
    % The preference directory exists
    cd(prefdir)
    % Check if the user created configuration file is saved in prefdir
    if(ispresent('configuration.txt','file'))
        % Read Configuration.txt file for level information
        content = textread('configuration.txt','%s');
    end
end
cd(cwd)
index = find(cell2array(strfind(content,'*'))==1);
namePattern = content(index(3)+1:index(4)-1);

rind = strmatch(lower(levelConvert('levelNo',nlevel)),namePattern);

if(~isempty(rind))
    r1 = namePattern{rind};
    r = [r1(1:min(find(r1(:)>=48&r1(:)<=57))-1) '*'];
else
    r = '';
end
    