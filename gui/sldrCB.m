function sldrCB (varargin)

% This function is not accessed by user.
%
% This function is called by other functions or GUIs to set the callback of
%   the slider and make the slider work as a windows scrolling bar.
% The input argument is the handle of the parent figure or panel.

handles = get(varargin{1}, 'UserData');
handlesData = handles{1};
handlesPos = handles{2};

if nargin > 1
    sldrPos = varargin{2};
else
    sldrPos = get(gcbo, 'Value');
end
numOptions = length(handlesData);
Pos = get(varargin{1}, 'Position');
height = Pos(4);

for jj = 1:numOptions
    if handlesPos{jj}(2) - sldrPos < .01 | handlesPos{jj}(2) + handlesPos{jj}(4) - sldrPos > height-.01
        set (handlesData(jj), 'Visible', 'off');
        set (handlesData(jj), 'Position', [handlesPos{jj}(1) handlesPos{jj}(2) - sldrPos, ...
                                           handlesPos{jj}(3) handlesPos{jj}(4)]);
    else
        set (handlesData(jj), 'Position', [handlesPos{jj}(1) handlesPos{jj}(2) - sldrPos, ...
                                           handlesPos{jj}(3) handlesPos{jj}(4)]);
        set (handlesData(jj), 'Visible', 'on');
    end

end