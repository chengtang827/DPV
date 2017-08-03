function [obj,varargout] = plot(obj,varargin)
%@nptgroup/plot Plot function for nptgroup class
%   OBJ = plot(OBJ,N,'Object',{'CLASS',{'PLOT_OPTIONS'},{'CONSTRUCTOR_
%   OPTIONS'}) loops over the cluster directories contained in OBJ, 
%   instantiates an object of the type CLASS with 'auto' and
%   'CONSTRUCTOR_OPTIONS', and calls the plot function of that object 
%   with 'PLOT_OPTIONS'. 
%
%   e.g. plot(ng,1,'Object',{'ispikes',{'chunkSize',4}});

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Object','','GroupEvent',0,'GroupPlotSep','','ReturnVars',{''}, 'ArgsOnly',0);
Args.flags = {'LabelsOff','GroupEvent', 'ArgsOnly'};
[Args,varargin2] = getOptArgs(varargin,Args, 'remove',{'GroupEvent'});

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

% default values for variables
groupN = 1;
cellN = 1;

% if there are numeric arguments, figure out who it is for
if(~isempty(Args.NumericArguments))
    if(Args.GroupEvent)
        groupN = Args.NumericArguments{1};
        if(groupN>obj.data.numSets)
            groupN = obj.data.numSets;
        end
    else
        cellN = Args.NumericArguments{1};
    end
end

% get relevant directories
startIndex = obj.data.numCellsIndex(groupN) + 1;
endIndex = obj.data.numCellsIndex(groupN + 1);
cellDirs = {obj.data.cellNames{startIndex:endIndex}};
% get number of directories
numDirs = endIndex - startIndex + 1;

plotObject = Args.Object;
% get number of columns in Object cell array
[oRows,oCols] = size(plotObject);
% there should be at least 1 column in plotObject and that should be
% the plot object
pObject = plotObject{1};
% set plotOptions and objOptions to empty cell array by default
plotOptions = {};
objOptions = {};
if(oCols>1)
	% get the plot options
	plotOptions = plotObject{2};
end
if(oCols>2)
	% get the constructor options
	objOptions = plotObject{3};
end

% check if we need to separate the plots
% instantiate empty object so we can query plot properties
emptyObject = feval(pObject);
sepaxis = 'No';
% get plot properties from object
if(numDirs>1)
	if(isempty(Args.GroupPlotSep))
		objPlotProps = get(emptyObject,'GroupPlotProperties',numDirs,plotOptions{:});
		sepaxis = objPlotProps.separate;
    else
        sepaxis = Args.GroupPlotSep;
	end
end
% get axes positions
axesPositions = separateAxis(sepaxis,numDirs);

% save current directory
origDir = pwd;
% go to group directory
cd(obj.data.setNames{groupN})
cwd=pwd;
% check oCols outside loop to optimize performance inside loop
colors = nptDefaultColors(1:numDirs);
h=[];
for i = 1:numDirs
	% change directory to each cell and call plot function for object
	cd(cellDirs{i})
	% instantiate object with arguments in 3rd column of Object
	thisObj= feval(pObject,'auto',objOptions{:});
	hc = subplot('Position',axesPositions(i,:));
	h = [h hc];
	% plot with arguments in 2nd column of Object
% 	try
% 		[thisObj, outputs] = plot(thisObj,cellN,plotOptions{:},'GroupPlots',numDirs, ...
% 			'GroupPlotIndex',i,'Color',colors(i,:));
%	catch
        % pass varargin2 to plot function so that arguments like LabelsOff
        % from nptdata/plot will be handled properly
		thisObj = plot(thisObj,cellN,plotOptions{:},'GroupPlots',numDirs, ...
			'GroupPlotIndex',i,'Color',colors(i,:),varargin2{:});
%	end
    % reset axis position since Matlab7 changes the dimensions of the axis
    % after plotting.
    if(strcmp(version('-release'),'14'))
        set(hc,'Position',axesPositions(i,:));
    end
	hold on
	cd(cwd)
end
if exist('outputs','var')
varargout{1} = {outputs{:},'handle',h};
end
% change the title
% title(getDataOrder('ShortName',obj.data.setNames{groupN}))
hold off
cd(origDir)

% return the arguments that the user has specified
rvarl = length(Args.ReturnVars);
if(rvarl>0)
    % assign requested variables to varargout
    for rvi = 1:rvarl
        varargout{1}{rvi*2-1} = Args.ReturnVars{rvi};
        varargout{1}{rvi*2} = eval(Args.ReturnVars{rvi});
    end
end
