function [] = runProcessLevel()
%RUNPROCESSLEVEL Separate the splitting into 4 jobs, generate a skipping
%marking file to skip the splitting in the last job.
% 
%   Detailed explanation goes here
channelId = [{1:32} ; {33:64} ; {65:96} ; {97:124}];

for i = 1:size(channelId,1)
    ProcessLevel(rplsplit,'skipCheckingMarkers',1,'Levels','Day','SaveLevels',3,...
        'SkipLFP',1,'UseHPC',1,'Channels',channelId{i,1},'skipCheckingRplsplit',1,...
        'HPCCmd','source ~/.bash_profile; qsub $GITHUB_MATLAB/Hippocampus/Compiler/rplsplit/rsHPC_submit_file.txt')
end

end


