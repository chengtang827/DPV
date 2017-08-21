function InspectFn(varargin)

% This function should not be accessed by the user.
%
% This function is called by other functions or GUIs,
%   e.g. nptdata/InpsectGUI and updatebutton_Callback function for
%   PlotOptions GUI, to call the plot function to do plotting,
%   and modify the properties of the plot, such as 'OverPlot', 'HoldAxis'
%   and 'LinkedZoom'.
%
% The first input argument is the handle of the parent figure;
% The second input argument is the eventnumber
% The rest optional input arguments depends on the calling function


h0 = varargin{1};
s = get(h0, 'UserData');
n = varargin{2};
figure(h0);
% initialize outputs in case conditions below are not met
outputs = '';

nobj = length(s.obj);
for ii=1:nobj
    cd(s.dir{ii})
    % subplot(nobj,1,ii)
    if(~s.OverPlot)
        if isempty(s.subplot)
            s.subplot = nptSubplot(nobj,ii,varargin{3:end});
        else
            a = s.subplot;
            subplot(a(1),a(2),ii);
            % need to call subplot a second time to work around problem when
            % using plotyy (see Solution Number: 1-19HLP in Mathworks's tech
            % solution database). This bug is supposed to be fixed in R14.
            subplot(a(1),a(2),ii);
        end
    end
    %pass optional arguments in a form that can be recognized as varargin
    if s.PopulationPlot
        try
            [s.obj{ii}, outputs] = plot(s.obj{ii}, s.optArgs{ii}{:},'ReturnVars',{'Args'});
        catch
        	% this is for old objects that have not been updated to use ReturnVars
            display(['Error: please add the argument ''ReturnVars'' to the ' ...
                'respective plot function! Refer to @dirfiles/PLOT.']);
            s.obj{ii} = plot(s.obj{ii}, s.optArgs{ii}{:});

        end
        edithandle = findobj(h0,'Tag','EditText1');
        set(edithandle,'String',num2str(n));
    else
        try
            [s.obj{ii}, outputs] = plot(s.obj{ii},n,s.optArgs{ii}{:},'ReturnVars',{'Args'});
        catch
        	% this is for old objects that have not been updated to use ReturnVars
            display(['Error: please add the argument ''ReturnVars'' to the ' ...
                'respective plot function! Refer to @dirfiles/PLOT.']);
            s.obj{ii} = plot(s.obj{ii},n,s.optArgs{ii}{:});
        end
    end
    
    Args = struct('Args',[],'handle',[],'xLimits',[]);
    s.Arg(ii) = getOptArgs(outputs,Args);
    
    if(s.OverPlot)
        hold on
    end
end

if(s.OverPlot)
    hold off
end

if s.HoldAxis
    ax = axis;
    % s.lm = limits(ax(3),ax(4));
    s.lm = [ax(3),ax(4)];
end


%set all axis to the same x range
h=[];
if(nobj>1 && ~s.OverPlot)
    for ii=1:size(s.Arg,2)
        if isfield(s.Arg(ii).Args,'LinkedZoom') & s.Arg(ii).Args.LinkedZoom==1
            h= [h , s.Arg(ii).handle];
            axes(h(1))
        end
    end
end
if(~isempty(h))
    LinkedZoom(h,'onx')
elseif s.LinkedZoom & length(findobj(h0,'Type','axes'))>1
    LinkedZoom(h0,'onx')
else
    zoom xon
end

f=fieldnames(s.obj{1});
if sum(strcmp(f,'title'))==1
    set(gcf,'Name',getfield(s.obj{1},'title'))
end
if sum(strcmp(f,'sessionname'))==1
    set(gcf,'Name',getfield(s.obj{1},'sessionname'))
end

% remove unnecessary field from s.Args
% for ii=1:nobj
%     % check for empty Args as it was causing errors
%     if(~isempty(s.Arg(ii).Args))
%     	try
% 			s.Arg(ii).Args = rmfield(s.Arg(ii).Args, {'NumericArguments', ...
% 				'GroupPlots', 'GroupPlotIndex', ...
% 				'ReturnVars', 'ArgsOnly'});
% 		catch
%         	% this is for old objects that have not been updated to use ReturnVars and ArgsOnly
% 			s.Arg(ii).Args = rmfield(s.Arg(ii).Args, {'NumericArguments', ...
% 				'GroupPlots', 'GroupPlotIndex'});
% 		end
%     end
% end

set (h0, 'UserData', {});
set(h0, 'UserData', s);