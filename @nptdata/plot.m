function [vw, varargout] = plot(vw,varargin)
%NPTDATA/PLOT Function for plotting nptdata
%   OBJ = PLOT(OBJ,N,VARARGIN) is a function that is usually overloaded
%   by children classes. It exists partially so that InspectGUI will 
%   not return an error if called without an object. If no optional
%   arguments are specified, the function does nothing.
%
%   The optional input arguments are:
%      'Objects' - Expects a cell array of the following form: {{'CLASS',
%                  {'PLOT_OPTIONS'},{'CONSTRUCTOR_OPTIONS'}}}. For each 
%                  directory in OBJ, an object of the type CLASS is 
%                  instantiated using 'auto' and 'CONSTRUCTOR_OPTIONS'
%                  and then the plot function is called with 'PLOT_
%                  OPTIONS'. 
%      'SubPlots' - Expects a vector ([ROWS,COLS]) that overrides the 
%                   arrangment of subplots returned by nptSubplot for
%                   multiple objects (default is []).
%      'DirsSubPlots' - Expects a vector ([ROWS,COLS]) that overrides
%                       the arrangment of subplots returned by nptSubplot
%                       for multiple directories (default is []).
%      'OverPlot' - Flag that indicates plots from multiple directories
%                   should be plotted on the same axis.
%  
%
%   e.g. plot(nd,1,'Objects',{{'performance'};{'bias',{'rt'}};{'bias'}});
%
%   Dependencies: None.

Args = struct('Objects',{''},'SubPlots',[],'DirsSubPlots',[],'OverPlot',0, 'ArgsOnly',0,'ReturnVars',{''},...
    'GroupPlots',1,'GroupPlotIndex',1);
Args.flags = {'OverPlot', 'ArgsOnly'};
Args = getOptArgs(varargin,Args);

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

if(~isempty(Args.NumericArguments))
	% make sure that numeric argument does not exceed number of sessiondirs
	dirnums = min([Args.NumericArguments{1} vw.number]);
    numdirs = 1;
else
    numdirs = vw.number;
	dirnums = 1:numdirs;
end

nobjs = size(Args.Objects,1);

if(numdirs>1 & (~Args.OverPlot))
	% get the layout and the number for the subplot which we will put labels on
	[dlayout,blnum] = nptSubplot(numdirs,'BottomLeft', ...
									'SubPlot',Args.DirsSubPlots);
else
    blnum = dirnums;                                
end

for n = dirnums
	% grab current directory
	cwd = pwd;
	% change to corresponding directory
	% call subsref so that the global variable nptDataDir will be checked
	a(1) = struct('type','.','subs','SessionDirs');
	% for some reason we need to use double cell arrays to make sure the 
	% argument will be passed on properly
	a(2) = struct('type','{}','subs',{{n}});
	cd(subsref(vw,a))
	
	if(numdirs>1 & (~Args.OverPlot))
		% only change layout if necessary
		subplot(dlayout(1),dlayout(2),n)
	end
	
	if( (nobjs>1) &(~Args.OverPlot) )
		if(isempty(Args.SubPlots))
			layout = nptSubplot(nobjs,1);
		else
			layout = Args.SubPlots;
		end
        changelayout = 1;
    else
        changelayout = 0;
    end

	% load objects
	for i = 1:nobjs
		try
            % get the number of cols for this object. Check here so the
            % user avoid having to type empty cell arrays when it is not
            % needed
            [oRows,oCols] = size(Args.Objects);
            % check if there is a 3rd column in this object
            if(oCols>2)
                % instantiate object with arguments in 3rd column of Objects
				thisObj = feval(Args.Objects{i,1},'auto',Args.Objects{i,3}{:});
            else
                % instantiate object with just the 'auto' argument
				thisObj = feval(Args.Objects{i,1},'auto');
            end
			% plot object
			if(changelayout)
                % only change layout if necessary
				subplot(layout(1),layout(2),i)	
			end
            if(~isempty(thisObj))
				if(n==blnum)
					if(oCols>1)
						plot(thisObj,Args.Objects{i,2}{:},'GroupPlots',nobjs,'GroupPlotIndex',i,'ReturnVars',{'Args'});
					else
						plot(thisObj,'GroupPlots',nobjs,'GroupPlotIndex',i,'ReturnVars',{'Args'});
					end
				else
					if(oCols>1)
						plot(thisObj,Args.Objects{i,2}{:},'LabelsOff','GroupPlots',nobjs,'GroupPlotIndex',i,'ReturnVars',{'Args'});
					else
						plot(thisObj,'LabelsOff','GroupPlots',nobjs,'GroupPlotIndex',i,'ReturnVars',{'Args'});
					end
				end
            else
                if(~Args.OverPlot)
                    cla
                    % remove title
                    title('');
                end
            end
			clear thisObj

            % turn hold on if we are doing OverPlots
            if(Args.OverPlot)
                hold on
            end            
		catch
			% get last error
			lm = lasterr;
			fprintf('Warning: Problem plotting %s object!\n', ...
				Args.Objects{i,1});
			fprintf('%s\n',lm);
		end
	end
	
    % turn hold on if we are doing OverPlots
    if(Args.OverPlot)
        hold on
    end
    
	% return to previous directory
	cd(cwd);
end

if(Args.OverPlot)
    hold off
end

% return the arguments that the user has specified
rvarl = length(Args.ReturnVars);
if(rvarl>0)
    % assign requested variables to varargout
    for rvi = 1:rvarl
        varargout{1}{rvi*2-1} = Args.ReturnVars{rvi};
        varargout{1}{rvi*2} = eval(Args.ReturnVars{rvi});
    end
end
