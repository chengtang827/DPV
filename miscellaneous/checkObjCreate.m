function n = checkObjCreate(varargin)
% This function is used to check the method to create the object 

Args = struct('ArgsC','','narginC','','firstVarargin','');
[Args,varargin] = getOptArgs(varargin,Args);
% create empty object by default
n = 'createObj';

% if user select 'ArgsOnly', return only Args structure for an empty object
% check for empty ArgsC as it was causing errors
if (~isempty(Args.ArgsC) && getfield(Args.ArgsC,'ArgsOnly'))
    n = 'createEmptyObjArgs';
    return;
end

if(Args.narginC==0)
    % create empty object
    n = 'createEmptyObj';
elseif( (Args.narginC==1) & isa(Args.firstVarargin{1},getfield(Args.ArgsC,'classname')))
    n = 'passedObj';
else
    % create object using arguments
    % check for empty ArgsC as it was causing errors
    if(~isempty(Args.ArgsC) && getfield(Args.ArgsC,'Auto'))
        % check for saved object
        % [pdir,cdir] = getDataOrder('session','relative','CDNow');
        if(ispresent(getfield(Args.ArgsC,'matname'),'file','CaseInsensitive') ...
                & (getfield(Args.ArgsC,'RedoLevels')==0))
                fprintf('Loading saved %s object...\n',getfield(Args.ArgsC,'classname'));
                l = load(getfield(Args.ArgsC,'matname'));
                robj = eval(['l.' getfield(Args.ArgsC,'matvarname')]);
                fprintf('\tComparing saved %s object arguments with new arguments specified...\n',getfield(Args.ArgsC,'classname'));
                %comparing
                sameFlag = checkArguments(Args.ArgsC,robj.data.Args);
                if(sameFlag)
                    fprintf('\tSaved %s object has same requested arguments...\n',getfield(Args.ArgsC,'classname'));
                    n = 'loadObj';
                else
                    fprintf('\tDifferent requested arguments, creating new %s object...\n',getfield(Args.ArgsC,'classname'));
                    n = 'createObj';
                end
        else
            % no saved object so we will try to create one
            % pass varargin in case createObject needs to instantiate
            % other objects that take optional input arguments
            n = 'createObj';
        end
    end
end