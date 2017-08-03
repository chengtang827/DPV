% --- Execute callback function for Update pushbutton on PlotOptions GUI
function updatebutton_Callback(hObject, eventdata, handles)
% hObject -- handle of the object, for which the callback was triggered. 
% eventdata -- reserved for later use. 
% handles -- structure with handles and userdata of all the objects in the figure.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ph is stored in the last position of handles
ph = handles{end};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pud = get(ph, 'UserData');
handles = handles{1};
numObjects = length(pud.obj);
numHandles = length(handles);
hpp = handles(numHandles - 5);
hlz = handles(numHandles - 4);
hop = handles(numHandles - 3);
hsp = handles(numHandles - 2);
hspval = handles(numHandles - 1);
numHandles = numHandles - 7;
handles = handles(1:numHandles);

% devide the handles to respective objects
objInd = 1;
for ii = 1:length(handles)
    if strcmp(get(handles(ii), 'String'), ['Object ', num2str(objInd), ':'])
        numOptions(objInd) = 0;
    elseif strcmp(get(handles(ii), 'String'), ['Object ', num2str(objInd+1), ':'])
        objInd = objInd + 1;
        numOptions(objInd) = 0;
    else
        numOptions(objInd) = numOptions(objInd) + 1;
    end
end

for ii = 1:numObjects
    for jj = 1:numOptions(ii)
        if ii < 2
            h_Obj{ii}{jj} = handles(jj+1);
        else
            h_Obj{ii}{jj} = handles(jj+ii+sum(numOptions(1:(ii-1))));
        end
    end
end


% edit handles as parameter-value pairs in a string array
for ii = 1:numObjects
    numArgs(ii) = 0;
    while ~isempty(h_Obj{ii})
        if strcmp(get(h_Obj{ii}{1}, 'Style'), 'checkbox')
            if get(h_Obj{ii}{1}, 'Value') == 1
                numArgs(ii) = numArgs(ii)+1;
                temCell2Str = get(h_Obj{ii}{1}, 'String');
                argObj{ii}{numArgs(ii)} = temCell2Str;
            end
            h_Obj{ii} = removeargs (h_Obj{ii}, 1, 1);
        elseif strcmp(get(h_Obj{ii}{1}, 'Style'), 'text')
            if strcmp(get(h_Obj{ii}{2}, 'Style'), 'edit')
                if ~isempty(get(h_Obj{ii}{2}, 'String'))
                    numArgs(ii) = numArgs(ii)+1;
                    temCell2Str = get(h_Obj{ii}{1}, 'String');
                    argObj{ii}{numArgs(ii)} = temCell2Str;
                    numArgs(ii) = numArgs(ii)+1;
                    if sum(strcmp(temCell2Str, {'Objects','Object'}))
                        argObj{ii}{numArgs(ii)} = eval(get(h_Obj{ii}{2},'String'));
                    else
                        if strcmp(get(h_Obj{ii}{2}, 'Tag'), 'n')
                            argObj{ii}{numArgs(ii)} = str2num(get(h_Obj{ii}{2}, 'String'));
                        else
                            argObj{ii}{numArgs(ii)} = get(h_Obj{ii}{2}, 'String');
                        end
                    end
                end
                h_Obj{ii} = removeargs(h_Obj{ii}, 1, 2);
            else
                h_Obj{ii} = removeargs(h_Obj{ii}, 1, 1);
            end
        elseif strcmp(get(h_Obj{ii}{1}, 'Style'), 'pushbutton')
            h_Obj{ii} = removeargs(h_Obj{ii}, 1, 1);
        end   
    end
end
          

% update pud.optArgs
pud.optArgs = [];
for ii = 1:numObjects
    for jj = 1:numArgs(ii)
        pud.optArgs{ii}{jj} = argObj{ii}{jj};
    end       
end
    
% update the value of pud.PopulationPlot
pud.PopulationPlot =  get(hpp, 'Value');

if pud.PopulationPlot
    pud.ev = event (1, 1);
else
    pud.ev = event(1,get(pud.obj{1},'Number',pud.optArgs{1}{:}));
    h1 = findobj(ph, 'Tag', 'EditText1');
    currentNum = str2num(get(h1, 'String'));
    pud.ev = SetEventNumber(pud.ev, currentNum);
end

% update the value of pud.LinkedZoom
pud.LinkedZoom = get(hlz, 'Value');

% update the value of pud.OverPlot
pud.OverPlot = get(hop, 'Value');

% update the value of pud.SubPlot
pud.subplot = str2num(get(hspval, 'String'));
    
% save updates in ph
set (ph, 'UserData', {});
set (ph, 'UserData', pud);


% close PlotOptions window
set(gcf, 'Visible', 'off');

InspectFn (ph, GetEventNumber(pud.ev));
