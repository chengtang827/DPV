function [spikeCount, stimLoc, theStim]= ProcessSession(~,sessionName,varargin)
%PROCESSSESSION Summary of this function goes here
%   Detailed explanation goes here



load('neuron_names.mat');

nArg = nargin - 2;

saveFlag = 0;
redoFlag = 0;

for i = 1:nArg
    arg = cell2mat(varargin{i});
    if ischar(arg)
        arg = lower(arg);
        switch arg
            case('save')
                saveFlag = 1;
            case('redo')
                redoFlag = 1;
        end
    end
end

cd(sessionName)
if ~redoFlag&&exist('psth.mat','file')
    %load and return
    load('psth.mat');
    %which gives obj var
    spikeCount = obj.spikeCount;
    stimLoc = obj.stimLoc;
    theStim = obj.theStim;
    cd ..
    return;
end

%create psth obj
trials = nptDir('trial*');
neuronnr = length(neurons);
trialnr = length(trials);

%extract the stimulus info
%default is target
stimLoc = zeros(trialnr,2);
stimTs = zeros(trialnr,1);

for i = 1:trialnr
    stim = load([pwd '\trial' sprintf('%02d', i) '\target.mat']);
    try
        stimLoc(i,1) = stim.target.row;
        stimLoc(i,2) = stim.target.column;
        stimTs(i) = stim.target.timestamp;
    catch
        stimLoc(i,1) = NaN;
        stimLoc(i,2) = NaN;
        stimTs(i) = NaN;
    end
end

%alignment of timing
%default is fullLen
[maxStimTs, ind] = max(stimTs);
alignment = maxStimTs - stimTs;

%create the psthObj
%extract spike info

spikes = cell(neuronnr,trialnr);
%iterate over the trials
minTs = maxStimTs;%just an initialization
maxTs = 0;
for k = 1:trialnr
    %iterate over the neurons
    for i = 1:neuronnr
        load(['trial' sprintf('%02d', k) '\' cell2mat(neurons(i)) '.mat']);
        spike = spike + alignment(k);
        spikes(i,k) = {spike};
        
        %keep track of the min and max timestamps
        minTs = min([minTs;spike]);
        maxTs = max([maxTs;spike]);
    end
end


%compute average over trials
%default is 100ms time bin
binLen = 100;
binnr = ceil((maxTs-minTs)/binLen);
spikeCount = zeros(neuronnr, trialnr, binnr);
theStim = maxStimTs/binLen;

%for each neuron

for i = 1:neuronnr
    %for each location
    for j = 1:trialnr
        for k = 1:binnr
            range = [(k-1)*binLen k*binLen];
            spike = cell2mat(spikes(i,j));
            spikeCount(i,j,k) = sum(spike>=range(1)&spike<=range(2));
        end
    end
    
end

obj.spikeCount = spikeCount;
obj.stimLoc = stimLoc;
obj.theStim = theStim;


if saveFlag
    save('psth','obj');
end

cd ..
end

