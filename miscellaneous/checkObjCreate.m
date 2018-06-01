function [n,robj] = checkObjCreate(varargin)
% This function is used to check the method to create the object 

Args = struct('ArgsC','','narginC','','firstVarargin','');
[Args,varargin] = getOptArgs(varargin,Args);
% create empty object by default
n = 'createObj';
robj = [];

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
        % check to make sure redo is not specified
		if(getfield(Args.ArgsC,'RedoLevels')==0)
			% check for saved object in current directory (useful for HTCondor jobs)
			if(~ispresent(getfield(Args.ArgsC,'matname'),'file','CaseInsensitive'))
				% check if Args structure contains ObjectLevel
				if(getfield(Args.ArgsC,'ObjectLevel'))
					% check for saved object in appropriate directory
					fprintf('No saved object found in the current directory. Checking designated directory...\n');
					[pdir,cdir] = getDataOrder(Args.ArgsC.ObjectLevel,'relative','CDNow');
					if(~ispresent(getfield(Args.ArgsC,'matname'),'file','CaseInsensitive'))
			            % no saved object so we will try to create one
			            % pass varargin in case createObject needs to instantiate
			            % other objects that take optional input arguments
			            n = 'createObj';
					else  % if(~ispresent(getfield(Args.ArgsC,'matname'),'file','CaseInsensitive'))
						% try to load object
						[n,robj] = checkSavedObject(Args);
			        end  % if(~ispresent(getfield(Args.ArgsC,'matname'),'file','CaseInsensitive'))
					% return to previous directory
					if(~isempty(cdir))
					    cd(cdir);
					end				
				else  % if(getfield(Args.ArgsC,'ObjectLevel'))
		            n = 'createObj';
				end  % if(getfield(Args.ArgsC,'ObjectLevel'))
			else  % if(~ispresent(getfield(Args.ArgsC,'matname'),'file','CaseInsensitive'))
				% try to load object
				[n,robj] = checkSavedObject(Args);
			end  % if(~ispresent(getfield(Args.ArgsC,'matname'),'file','CaseInsensitive'))
		else  % if(getfield(Args.ArgsC,'RedoLevels')==0)
			% redo specified, so create new object
            n = 'createObj';
		end  % if(getfield(Args.ArgsC,'RedoLevels')==0)
	end  % if(~isempty(Args.ArgsC) && getfield(Args.ArgsC,'Auto'))
end  % if(Args.narginC==0)

function [n,obj] = checkSavedObject(Args)
    fprintf('Loading saved %s object...\n',getfield(Args.ArgsC,'classname'));
    l = load(getfield(Args.ArgsC,'matname'));
    robj = eval(['l.' getfield(Args.ArgsC,'matvarname')]);
    fprintf('\tComparing saved %s object arguments with new arguments specified...\n',getfield(Args.ArgsC,'classname'));
    %comparing
    rdata = robj.data;
    sameFlag = checkArguments(Args.ArgsC,rdata.Args);
    if(sameFlag)
        fprintf('\tSaved %s object has same requested arguments...\n',getfield(Args.ArgsC,'classname'));
        n = 'loadObj';
		obj = robj;
    else
        fprintf('\tDifferent requested arguments, creating new %s object...\n',getfield(Args.ArgsC,'classname'));
        n = 'createObj';
		obj = [];
    end

