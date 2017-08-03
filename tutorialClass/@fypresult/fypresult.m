function [obj, varargout] = fypresult(varargin)
%@dirfiles Constructor function for DIRFILES class
%   OBJ = dirfiles(varargin)
%
%   OBJ = dirfiles('auto') attempts to create a DIRFILES object by ...
%   
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on dirfiles %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = dirfiles('save','redo')
%
%dependencies: 

Args = struct('RedoLevels',0,'SaveLevels',0,'Auto',0,'ArgsOnly',0,'filter',0);
%filter 1 being dilate, filter 2 = protect with limits
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.UnimportantArgs = {'RedoLevels','SaveLevels'};                            

[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject

 Args.classname = 'fypresult';
 Args.matname = [Args.classname '.mat'];
 Args.matvarname = 'fypresult';

%To decide the method to create or load the object
command = checkObjCreate('ArgsC',Args,'narginC',nargin,'firstVarargin',varargin);

if(strcmp(command,'createEmptyObjArgs'))
    varargout{1} = {'Args',Args};
    obj = createEmptyObject(Args);
elseif(strcmp(command,'createEmptyObj'))
    obj = createEmptyObject(Args);
elseif(strcmp(command,'passedObj'))
    obj = varargin{1};
elseif(strcmp(command,'loadObj'))
    l = load(Args.matname);
    obj = eval(['l.' Args.matvarname]);
elseif(strcmp(command,'createObj'))
    % IMPORTANT NOTICE!!! 
    % If there is additional requirements for creating the object, add
    % whatever needed here
    obj = createObject(Args,varargin{:});
end


function obj = createEmptyObject(Args)
data.numSets = 0;
data.setNames = '';
%data.dlist = [];
data.setIndex = [];
data.original=[];
data.dilateRC=[];
data.limit=[];
data.fr=[];
data.protectedRC=[];
data.output1=[];
data.output2=[];
data.output3=[];
d.data = data;
data.Args = Args;
n=nptdata(0,0);
obj = class(d,Args.classname,n);


function obj = createObject(Args,varargin)

% cwd = pwd;
% cd /opt/data/cat
% s = textread('mseqcells.txt','%s');   
% s0 = strrep(s,'\','/');
% s1 = strcat([pwd filesep],s0); 
% ndmseq = nptdata('SessionDirs',s1);
% 
% s=textread('mseqcellsmovie.txt','%s');
% s0 = strrep(s,'\','/');
% s1 = strcat([pwd filesep],s0); 
% ndmoviecells = nptdata('SessionDirs',s1);
% cd(cwd);

% s2 = nptdata('SessionsFile','movie-cells.txt');
% s3 = strcat([pwd filesep],s2.SessionDirs);
% ndmoviecells = nptdata('SessionDirs',s3);
% cd(cwd);

%try to get rc
rc = revcorr('auto','FrameLevel','RedoLevels',3);
rc = flipRC(rc);
rc.data.R = rc.data.R - 0.5;
data.original = rc.data.R;

%dilate
data.dilateRC=dilateRC(rc);
%protected
[data.limit,data.protectedRC]=protectRC(rc);
frame = getframe;

data.output1 = framedotrc(frame,data.original)';
data.output2 = framedotrc(frame,data.dilateRC)';
data.output3 = framedotrc(frame,data.protectedRC)';

%data.fr = getFR(rc,ndmseq,ndmoviecells);
sd = getEquivData(varargin{:});
% get current directory
cwd = pwd;
pwd
cd(sd)
% grab related data
pwd
fr = firingrate('auto','Rate','Repetitions');
data.fr = fr.data.firingRate';
% return to previous directory
cd(cwd)


data.numSets=1;
% 
% switch(Args.filter)
%     case(1)
%         fprintf('dilate');
%     case(2)
%         fprintf('protected');
%     otherwise
%         fprintf('No filtering');
%end
%d.data=data;
    data.setNames = pwd;

    data.Args = Args;
	n = nptdata(data.numSets,0,pwd);
	d.data = data;
	obj = class(d,Args.classname,n);
	saveObject(obj,'ArgsC',Args);

%obj=class(d,Args.classname);

%end

function dRC = dilateRC(rc)

noiseRC = rc.data.R(:,:,1);
noiseRC = noiseRC(:);
std1 = std(noiseRC);
mean1 = mean(noiseRC);
max1 = mean1 + std(noiseRC);
min1 = mean1 - std(noiseRC);
max1=3*max1;
min1=3*min1;

newRC=rc;
bw=zeros(64);
bw(25:39,25:39)=1;
roi = (rc.data.R(:,:,:)<max1&rc.data.R(:,:,:)>min1);
roi = ~roi;
%roi = rc.data.R(:,:,:)>max1;
se=strel('square',3);

for page=1:7
    roi(:,:,page)=(roi(:,:,page)&bw);
end    

roi=imdilate(roi,se);

newRC.data.R((roi==0))=0;
dRC = newRC.data.R;

%end

function [limit,pRC] = protectRC(rc)

noiseRC = rc.data.R(:,:,1);
noiseRC = noiseRC(:);
std1 = std(noiseRC);
mean1 = mean(noiseRC);
max1 = mean1 + std(noiseRC);
min1 = mean1 - std(noiseRC);
max1=3*max1;
min1=3*min1;

newRC=rc;

bw=zeros(64);
bw(17:40,23:44)=1;
roi = (rc.data.R(:,:,:)<max1&rc.data.R(:,:,:)>min1);
roi = ~roi;
%roi = rc.data.R(:,:,:)>max1;


for page=1:7
    roi(:,:,page)=(roi(:,:,page)&bw);
    roi(:,:,page)=(roi(:,:,page));
end    

shape = zeros(64);
for n=1:7
shape = shape+roi(:,:,n);
end

[i,j]=find(shape);
limit = [min(i),max(i),min(j),max(j)];

roi(:)=0;
roi(min(i):max(i),min(j):max(j),:)=1;


%end
newRC.data.R((roi==0))=0;
pRC=newRC.data.R;

%end

function frame = getframe
k = pwd;
gf = k(29:47);
switch(gf)
    case {'a2/site05/session25'}
        cd '/var/automount/opt/home/hongwee/matlab/frame/everest2701';
    case {'a4/site03/session12'}
        cd '/var/automount/opt/home/hongwee/matlab/frame/cats2761';    
    case {'a4/site04/session16'}
        cd '/var/automount/opt/home/hongwee/matlab/frame/cats2471';  
    case {'a4/site05/session26'}
        cd '/var/automount/opt/home/hongwee/matlab/frame/cats2471';  
    case {'t2/site02/session05'}
        cd '/var/automount/opt/home/hongwee/matlab/frame/biglebowski1002';
    case {'t2/site03/session14'}
        cd '/var/automount/opt/home/hongwee/matlab/frame/biglebowski1702';
    otherwise
        warning('unknown movie stimulus');
        return;
end

    load matlab.mat; 
    cd(k);
    frame = multiframe;
%end

function output = framedotrc(frame,rc)
k=size(frame);
iteration = k(3)-7;
R = zeros(iteration,1);
mv = zeros(64,64,7);
rcc =rc(:)';

for n = 0:iteration
    mv(:,:,1)=frame(:,:,n+1);
    mv(:,:,2)=frame(:,:,n+2);
    mv(:,:,3)=frame(:,:,n+3);
    mv(:,:,4)=frame(:,:,n+4);
    mv(:,:,5)=frame(:,:,n+5);
    mv(:,:,6)=frame(:,:,n+6);
    mv(:,:,7)=frame(:,:,n+7);
    
    mvv = mv(:);
    
    R(n+1) = rcc*mvv;
    
end
    
output = R;
          
% end

% function fr = getFR(obj,ndmseq,ndmoviecells)
% %k=ProcessDays(obj,'Movie','Cells',get(ndmseq,'SessionDirs'), 'EquivalentSessions',get(ndmoviecells,'SessionDirs'));
% sd = getEquivData(varargin2{:});
% % get current directory
% cwd = pwd;
% 
% cd(sd)
% % grab related data
%     fr = firingrate('auto','Rate','Repetitions')
% % return to previous directory
% cd(cwd)
% end

    