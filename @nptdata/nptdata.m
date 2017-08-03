function [n,varargout] = nptdata(varargin)
%nptdata Constructor function for NPTDATA object
%   N = nptdata(NUMBER,HOLDAXIS,DIRECTORY) instantiates an NPTDATA 
%   object with NUMBER of events. The object contains the following 
%   fields:
%      N.number - Number of events
%      N.holdaxis - Either 0 or 1 specifying whether the axis is
%                   rescaled for each plot (0) or only if the limits
%                   change (1).
%      N.sessiondirs - Cell array containing directory paths where
%                      precomputed objects are located.
%   The first two arguments are mandatory in this form. If the third
%   argument is not present, the sessiondirs field is left empty.
%
%   N = nptdata('SessionDirs',DIRS,'HoldAxis',HOLDAXIS) instantiates 
%   an NPTDATA object using DIRS, which is a cell array with each row 
%   containing a directory path where precomputed objects are located 
%   (default is empty). The number field is set to the number of rows 
%   in DIRS, and the holdaxis field is set to HOLDAXIS if it is
%   specified (default: 0).
%
%   N = nptdata('SessionsFile',FILENAME) instantiates an NPTDATA object 
%   using  the text file FILENAME, which contains a directory path on
%   each line. 
%
%   N = nptdata('Eval',EVAL_STRING) instantiates an empty NPTDATA 
%   object if EVAL_STRING evaluates to false, and sets the number
%   field to 1 and the sessiondirs field to the current directory.
%
%   e.g. nd = nptdata('SessionDirs',{'070203/02';'070203/03'});
%   e.g. nd = nptdata('SessionsFile','sessions.txt');
%   e.g. nd = nptdata('Eval',''ispresent(''bigroups.mat'',''file'')');
%
%   Dependencies: getOptArgs.
%   n = nptdata(1,1,'SessionDirs',{},'SessionsFile',{},'Eval','');

% for some reason if empty string not included in empty cell array, Args
% does not get created properly
Args = struct('SessionDirs',{''},'SessionsFile','','Eval','', ...
	'HoldAxis',0,'Auto',0,'ArgsOnly',0);
Args.flags = {'Auto','ArgsOnly'};
Args = getOptArgs(varargin,Args);


% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    varargout{1} = {'Args',Args};
    n = createEmptyObject(Args);
    return;
end

if(Args.Auto)
    % create nptdata using current working directory
    n.number = 1;
    n.holdaxis = 0;
    n.sessiondirs = {pwd};
    n = class(n,'nptdata');
elseif(~isempty(Args.SessionsFile))
	% use textread to return cell array
	%Args.SessionDirs = textread(Args.SessionsFile,'%s\n');
    Args.SessionDirs = textread(Args.SessionsFile,'%s');
	% since the directories will be arranged in rows, get the number of
	% rows
	n.number = size(Args.SessionDirs,1);
	n.holdaxis = Args.HoldAxis;
	% cell arrays are easier to use when the entries are stored in 
	% columns so transpose them
	n.sessiondirs = {Args.SessionDirs{:}};
	n = class(n,'nptdata');
elseif(~isempty(Args.Eval))
	% evaluate string
	status = eval(Args.Eval);
	if(status)
		% string evaluated true so create object using current directory
		n.number = 1;
		n.holdaxis = Args.HoldAxis;
		n.sessiondirs = {pwd};
		n = class(n,'nptdata');
	else
		% string evaluated false so create empty object
		n.number = 0;
		n.holdaxis = 0;
		n.sessiondirs = {};
		n = class(n,'nptdata');
	end
elseif(~isempty(Args.SessionDirs))
	if(~iscell(Args.SessionDirs))
		% make sure SessionDirs is cell array
		Args.SessionDirs = {Args.SessionDirs};
	else
		% make sure entries in SessionDirs are in columns
		Args.SessionDirs = {Args.SessionDirs{:}};
	end
	% get number from number of columns of SessionDirs
	n.number = size(Args.SessionDirs,2);
	n.holdaxis = Args.HoldAxis;
	n.sessiondirs = Args.SessionDirs;
	n = class(n,'nptdata');
else
	% no optional input arguments specified so the call must be the
	% 2 or 3 argument type
	switch nargin
	case 0
		n = createEmptyObject(Args);
	case 1
		% get first argument
		v1 = varargin{1};
		% check if v1 is a nptdata object or if it is derived from 
		% the nptdata class
		if (isa(v1,'nptdata'))
            if(strcmp(class(v1),'nptdata'))
            	% v1 is a nptdata object so just return it
    			n = v1;
		    else
		    	% v1 is derived from a nptdata object but we don't know
		    	% how many levels down so we will just use the get 
		    	% function to get the values for the nptdata and 
		    	% recreate it
				n.number = get(v1,'Number');
				n.holdaxis = get(v1,'HoldAxis');
				n.sessiondirs = get(v1,'SessionDirs');
				n = class(n,'nptdata');
            end
        else
			error('Wrong argument type')
		end
	case 2	
		n.number = varargin{1};
		n.holdaxis = varargin{2};
		n.sessiondirs = {};
		n = class(n,'nptdata');
	case 3
		n.number = varargin{1};
		n.holdaxis = varargin{2};
		% check if 3rd argument is a cell array
		if(~iscell(varargin{3}))
			n.sessiondirs = {varargin{3}};
		else
			n.sessiondirs = varargin{3};
		end
		n = class(n,'nptdata');
	otherwise
		error('Wrong number of arguments!');
	end
end

function obj = createEmptyObject(Args)

n.number = 0;
n.holdaxis = 0;
n.sessiondirs = {};
obj = class(n,'nptdata');
