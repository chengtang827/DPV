function strVal = cell2str (cellVal);

% This function converts the input cell array into string.
%
% The input cell array can only contain strings and numeric values.
% If the input argument does not satisfy the prerequisite, an error message 
% will be displayed, and the function will return a empty string.


% if the input argument is not a cell
if ~iscell(cellVal)
    disp ('Error: the input argument is not a cell!');
    strVal = '';
    return;
end

% if the input cell is empty
if isempty(cellVal);
    strVal = '{}';
    return;
end

% if the input cell is not empty
strVal = '{';

numRow = size(cellVal, 1);
numCol = size(cellVal, 2);
for rr = 1:numRow
    for cc = 1:numCol
        if ischar(cellVal{rr, cc})
            strVal = [strVal, '''', cellVal{rr, cc}, ''','];
        elseif isnumeric(cellVal{rr, cc})
            strVal = [strVal, '[', num2str(cellVal{rr, cc}), '],'];
        elseif iscell(cellVal{rr, cc})
            strEleVal = cell2str(cellVal{rr, cc});
            strVal = [strVal, strEleVal, ','];
        else    % if the input argument contains invalid element
            disp('Error: the input argument contains invalid element!');
            strVal = '';
            return;
        end
    end
    strVal(length(strVal)) = ';';
end

strVal(length(strVal)) = '}';
        
