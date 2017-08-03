function [obj, varargout] = plot(obj,varargin)
%@checkFiles/plot Plot function for checkFiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
    'ReturnVars',{''}, 'ArgsOnly',0,'AllFiles',1,'MatFile',0,'BinFile',0,...
    'TxtFile',0);
Args.flags = {'LabelsOff','ArgsOnly','AllFiles','MatFile','BinFile','TxtFile'};
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

if(isempty(Args.NumericArguments))
    if(Args.MatFile)
        x = 1:1:length(obj.data.fdir);
        y = obj.data.nmat;
        plot(x,y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','r',...
            'MarkerSize',10)
        hold on
    end
    if(Args.BinFile)
        x = 1:1:length(obj.data.fdir);
        y = obj.data.nbin;
        plot(x,y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','y',...
            'MarkerSize',10)
        hold on
    end
    if(Args.TxtFile)
        x = 1:1:length(obj.data.fdir);
        y = obj.data.ntxt;
        plot(x,y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','b',...
            'MarkerSize',10)
        hold on
    end
    if(Args.AllFiles)
        x = 1:1:length(obj.data.fdir);
        y = obj.data.nfile;
        plot(x,y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','g',...
            'MarkerSize',10)
    end
    xlabelstr = 'Directory';
    ylabelstr = 'Number of mat files';
    hold off
else
    a = Args.NumericArguments{1};
    n = a(1,1);
    if(Args.MatFile)
        y = obj.data.nmat(n);
        plot(y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','r',...
            'MarkerSize',10)
        hold on
    end
    if(Args.BinFile)
        y = obj.data.nbin(n);
        plot(y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','y',...
            'MarkerSize',10)
        hold on
    end
    if(Args.TxtFile)
        y = obj.data.ntxt(n);
        plot(y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','b',...
            'MarkerSize',10)
        hold on
    end
    if(Args.AllFiles)
        y = obj.data.nfile(n);
        plot(y,'--rs','LineWidth',2,...
            'MarkerEdgeColor','k',...
            'MarkerFaceColor','g',...
            'MarkerSize',10)
    end
    xlabelstr = 'Directory';
    ylabelstr = 'Number of mat files';
    axis([0 2 0 4])
    hold off
end
if(~Args.LabelsOff)
    xlabel(xlabelstr);
    ylabel(ylabelstr);
end

RR = eval('Args.ReturnVars');
for i=1:length(RR) RR1{i}=eval(RR{i}); end 
varargout = getReturnVal(Args.ReturnVars, RR1);