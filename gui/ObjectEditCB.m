function varargout = ObjectEditCB(varargin)

if nargin < 2
    handles = guidata(gcbf);
else
    handles = guidata(varargin{2});
end

if ~isempty(varargin) & ischar(varargin{1})
    lable = varargin{1};
else
    lable = get(gcbo, 'Tag');
end

switch lable
    case 'objName'
        objOptStrList = get(gcf, 'UserData');
        set(varargin{1}, 'String', objOptStrList{get(gcbo, 'Value')}); 
        
        
    case 'Delete'
        objNameList = get(varargin{1}, 'String');
        objNameInd = get(varargin{1}, 'Value');
        objOptStrList = get(gcf, 'UserData');
        newObjNameList = {};
        newObjOptStrList = {};
        newObjNameList = {objNameList{1:(objNameInd-1)}, objNameList{(objNameInd+1):length(objNameList)}};
        newObjOptStrList = {objOptStrList{1:(objNameInd-1)}, objOptStrList{(objNameInd+1):length(objNameList)}};
        
        set(varargin{1}, 'String', newObjNameList);
        set(varargin{1}, 'Value', []);
        set(varargin{2}, 'String', '');
        set(gcf, 'UserData', newObjOptStrList);
        
        
    case 'Modify'
        if isfield(handles, 'modify')
            figure(handles.modify);
        elseif isempty(get(varargin{2}, 'String'))
            display('Error: please add an object first!');
        elseif isempty(get(varargin{2}, 'Value'))
            display('Error: please select an object!');
        else
            ObjectGUI(varargin{:});
        end
           
        
    case 'Add'
        if isfield(handles, 'add')
            figure(handles.add);
        else
            ObjectGUI(varargin{1});
        end
        
    case 'Edit'
        plotOptHandles = guidata(varargin{1});
        if isfield(plotOptHandles, 'objEdit')
            figure(plotOptHandles.objEdit);
        else
            objectEdit(varargin{:});
        end
        
        
    case 'editDone'
        objOptStrList = get(gcbf, 'UserData');
        hObjName = findobj(gcbf, 'Tag', 'objName');
        objNameList = get(hObjName, 'String');
        objString = '';
        for ii = 1:length(objNameList)
            objString = [objString '{''' objNameList{ii} ''''];
            if strcmp(objOptStrList{ii}, 'None')
                objString = [objString '}'];
            else
                objString = [objString ', ' objOptStrList{ii} '}'];
            end
            if ii~=length(objNameList)
                objString = [objString '; '];
            end
        end
        
        hEditObject = varargin{3};
        if isempty(hEditObject)
            hEditObject = findobj(handles.parFig, 'Tag', 'editObjects');
            objString = ['{' objString '}'];
        end
        set(hEditObject, 'String', objString);
        
        close(handles.output);
        try
            figure(handles.parFig);
        catch
            figure(get(handles.parFig,'Parent'));
        end
        
        
    case 'Quit'
        if isfield(handles, 'add')
            ObjectCB('Quit', handles.add);
        end
        if isfield(handles, 'modify')
            ObjectCB('Quit', handles.modify);
        end
        
        parHandles = guidata(handles.parFig);
        parHandles = rmfield(parHandles, 'objEdit');
        guidata(handles.parFig, parHandles);
        delete(handles.output);
        
end