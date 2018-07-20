function [] = runProcessLevel()
%RUNPROCESSLEVEL Separate the splitting into 4 jobs, generate a skipping
%marking file to skip the splitting in the last job.
% 
%   Detailed explanation goes here
ProcessLevel(rplsplit,'Levels','Day','SaveLevels',3,'SkipLFP',1,'UseHPC',1,'Channels',1:32,...
    'HPCCmd','source ~/.bash_profile; qsub $GITHUB_MATLAB/Hippocampus/Compiler/rplsplit/rsHPC_submit_file.txt')

pause(30)

ProcessLevel(rplsplit,'Levels','Day','SaveLevels',3,'SkipLFP','SkipParallel','SkipAnalog',1,'UseHPC',1,'Channels',33:64,...
    'HPCCmd','source ~/.bash_profile; qsub $GITHUB_MATLAB/Hippocampus/Compiler/rplsplit/rsHPC_submit_file.txt')

pause(30)

ProcessLevel(rplsplit,'Levels','Day','SaveLevels',3,'SkipLFP','SkipParallel','SkipAnalog',1,'UseHPC',1,'Channels',65:96,...
    'HPCCmd','source ~/.bash_profile; qsub $GITHUB_MATLAB/Hippocampus/Compiler/rplsplit/rsHPC_submit_file.txt')

pause(30)

ProcessLevel(rplsplit,'Levels','Day','SaveLevels',3,'SkipLFP','SkipParallel','SkipAnalog',1,'UseHPC',1,'Channels',97:124,...
    'HPCCmd','source ~/.bash_profile; qsub $GITHUB_MATLAB/Hippocampus/Compiler/rplsplit/rsHPC_submit_file.txt')


end


