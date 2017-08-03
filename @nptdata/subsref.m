function [b,res] = subsref(obj, index)
%NPTDATA/SUBSREF Index function for NPTDATA object.
%
%   Dependencies: None.

res = 1;
myerror = 0;

% get length of index
indlength = length(index);

switch index(1).type
case '.'
	switch index(1).subs
	case 'number'
		b = obj.number;
	case 'holdaxis'
		b = obj.holdaxis;
	case 'SessionDirs'
		if(indlength==1)
			b = obj.sessiondirs;
		else
			b = subsref(obj.sessiondirs,index(2:end));
		end
        % check if b is empty
        if(~isempty(b))
            % check to see if we need to change the directory prefix
            % the user will have to have set nptDataDir in the workspace
            global nptDataDir onptDataDir
            if(~isempty(nptDataDir))
            	% check if onptDataDir is set
            	if(isempty(onptDataDir))
                    % check if b is a cell array which means that b is the
                    % entire sessiondirs cell array
                    if(iscell(b))
                        % just get the first cell array since we are going to
                        % assume that they are all going to have the same data
                        % directory prefix
                        bdir = b{1};
                    else
                        bdir = b;
                    end
					% figure out the original data directory prefix
					% save it to a local variable so we don't set the global
					% variable if it is not already set
					odir = getDataOrder('days','DirString',bdir);
				else % if(isempty(onptDataDir))
					% use the directory set by the user
					% useful if the session directories do not conform to
					% the format expected by getDataOrder
					odir = onptDataDir;
				end % if(isempty(onptDataDir))
                % replace the original directory with the directory in
                % nptDataDir
                b = strrep(b,odir,nptDataDir);
                % replace '\' with '/' in case the old directory was from
                % Windows
                b = strrep(b,'\','/');
            end % if(~isempty(nptDataDir))
        end % if(~isempty(b))
	otherwise 
		% since nptdata does not inherit from any other object
		% go ahead and indicate error
		myerror = 1;
	end
otherwise
	myerror = 1;
end

if myerror == 1
	if isempty(inputname(1))
		% means some other function is calling this function, so
		% just return error instead of printing error
		res = 0;
		b = 0;
	else
		error('Invalid field name')
	end
end
