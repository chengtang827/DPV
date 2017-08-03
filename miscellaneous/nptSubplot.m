function [a,varargout] = nptSubplot(n,varargin)
%nptSubplot Creates reasonable layout of subplots
%   A = nptSubplot(N,P) creates subplots with N being total number 
%   of plots and P being the current plot and returns layout in A 
%   ([rows cols]). Useful when calling subplot with a variable number 
%   of subplots.
%
%   A = nptSubplot(N,P,'SubPlot',[Rows Cols]) over-rides the default
%   layout.
%
%   A = nptSubplot(N,'BottomLeft') selects the subplot in the
%   bottom-left corner. This option can also be used with the
%   'SubPlot' option to over-ride the default layout and select the
%   subplot in the bottom-left corner.

Args = struct('SubPlot',[],'BottomLeft',0);
Args.flags = {'BottomLeft'};
Args = getOptArgs(varargin,Args);

varargout = {};

if(~isempty(Args.SubPlot))
    % over-ride default layout
    a = Args.SubPlot;
    r = a(1);
    c = a(2);
else
    switch n
        case 1
            r=1;c=1;
        case 2 
            r=1;c=2;
        case 3
            r=1;c=3;
        case 4
            r=2;c=2;
        case {5,6}
            r=2;c=3;
        case {7,8,9}
            r=3;c=3;
        case {10,11,12}
            r=3;c=4;
        case {13,14,15,16}
            r=4;c=4;
        case {17,18,19,20}
            r=4;c=5;
        otherwise
            r=5;
            c=ceil(n/5);
    end
    % return layout
    a = [r c];
end

if(Args.BottomLeft)
	% select the plot in the bottom left corner
	bl = (r-1)*c+1;
	subplot(r,c,bl);
	varargout{1} = bl; 
else
	% get specified subplot number
	p = Args.NumericArguments{1};
	subplot(r,c,p);
end
