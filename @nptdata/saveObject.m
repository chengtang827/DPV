function n = saveObject(obj,varargin)
% This function is used to save the created object.
% Args = struct('SaveLevelsC','','classnameC','','matnameC','','matvarnameC','');
Args = struct('ArgsC','');
[Args,varargin] = getOptArgs(varargin,Args);

robj = obj;
n = 0;
% added check for empty ArgsC as it was causing errors, possibly from
% changing Matlab version to R2015a
if(~isempty(Args.ArgsC) && getfield(Args.ArgsC,'SaveLevels'))
    fprintf('Saving %s object...\n',getfield(Args.ArgsC,'classname'));
    eval([getfield(Args.ArgsC,'matvarname') ' = robj;']);
    % save object
    eval(['save ' getfield(Args.ArgsC,'matname') ' ' getfield(Args.ArgsC,'matvarname') ' -v7.3']);
    n = 1;
end
