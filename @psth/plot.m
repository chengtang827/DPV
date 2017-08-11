function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'NeuronIndex',1,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
    'ReturnVars',{''}, 'ArgsOnly',0);
Args.flags = {'LabelsOff','ArgsOnly'};
[Args,varargin2] = getOptArgs(varargin,Args);

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

if(~isempty(Args.NumericArguments))
    % plot one data set at a time
    n = Args.NumericArguments{1};
else
    % plot all data
    n = 1;
end

% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
locations = {[2 2];[2 3];[2 4];[3 2];[3,3];[3 4]; [4 2]; [4 3]; [4 4]};

stimLoc = obj.data.session(n).stimLoc;
spikeCount = obj.data.session(n).spikeCount;
theStim = obj.data.session(n).theStim;

neuronIndex = Args.NeuronIndex;

for i = 1:length(locations)
    location = locations{i};    
    temp = stimLoc==location;
    index = temp(:,1)&temp(:,2);
    selected = spikeCount(:,index,:);
    psth = squeeze(mean(selected,2));
    subplot(3,3,i);
    plot(psth(neuronIndex,:));
    line([theStim theStim], [0 max(psth(neuronIndex,:))])
end
% @dirfiles/PLOT takes 'LabelsOff' as an example
if(~Args.LabelsOff)
    xlabel('X Axis')
    ylabel('Y Axis')
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars');
for i=1:length(RR) RR1{i}=eval(RR{i}); end
varargout = getReturnVal(Args.ReturnVars, RR1);
