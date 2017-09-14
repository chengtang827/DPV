function n = checkArguments(p,q,varargin)
% This function is used to check the if the saved arguments in q are the 
% same as the ones specified now in p. If the two are the same, we can 
% load the saved object directly. If not, we need to create the object 
% again using the arguments specified now.

% 'UnimportantArgs' means the arguments whose values can be ignored
n=0;
Args = struct('DataCheckArgs','');
[Args,varargin] = getOptArgs(varargin,Args);

Args.DataCheckArgs = getfield(p,'DataCheckArgs');
% check if there are no arguments to check
if(isempty(Args.DataCheckArgs))
	n = 1;
	return;
end

% count indicates the number of arguments with same values
count = 0;

% Make sure p and q are Args, i.e., structures
if(isstruct(p)&&isstruct(q))
	% Get an array of field name (argument) for p and q, respectively
	pa = fieldnames(p);
	qa = fieldnames(q);
    % Get the number of fields (arguments) in the struct
    pl = length(pa);
    % ql = length(qa);
	for i = 1:pl
		pfield = pa{i};
		% check if this is an argument that should be checked
		if(sum(strcmp(pfield,Args.DataCheckArgs)) == 1)
			% check for a match in qa in case the order of the arguments are 
			% not the same
			qi = find(strcmp(pfield,qa));
			if(~isempty(qi))
				% Get value for this field
				pp = getfield(p,pfield);
				qq = getfield(q,qa{qi});
				k = 0;
				% Check if the field name is one of the unimportant ones
				% i.e., the arguments can be ignored
				% Args can only be one of the following data types
				if(isempty(pp)&isempty(qq))
					k = 1;
				elseif(islogical(pp)&islogical(qq))
					if(pp==qq)
						k = 1;
					end
				elseif(ischar(pp)&ischar(qq))
					if(strcmp(pp,qq))
						k = 1;
					end
				elseif(isnumeric(pp)&isnumeric(qq))
					if(pp==qq)
						k = 1;
					end
				elseif(isstruct(pp)&isstruct(qq))
					if(checkArguments(pp,qq))
						k = 1;
					end
				elseif(iscell(pp)&iscell(qq))
					if(checkcell(pp,qq))
						k = 1;
					end
				end
				count = count + k;
			end % if(~isempty(qi))
		end % if(sum(strcmp(pfield,Args.UnimportantArgs) == 0))
	end % for i = 1:pl

	% if count is equal to the total number of arguments minus that can
	% be ignored, then return 1
	if(count==(pl-length(Args.UnimportantArgs)))
		n = 1;
	end
end

%{	
    
    % Make sure the number of feilds in p and q are the same
    if(pl==ql)
        % Get an array of field name (argument) for p and q, respectively
        pa = fieldnames(p);
        qa = fieldnames(q);
        for i = 1:pl
            % Get each individual field name (argument)
            pp = getfield(p,pa{i});
            qq = getfield(q,qa{i});
            k = 0;
            % Check if the field name is one of the unimportant ones
            % i.e., the arguments can be ignored
            if(~sum(strcmp(pa{i},Args.UnimportantArgs)) && ~sum(strcmp(qa{i},Args.UnimportantArgs)))
                % Args can only be one of the following data types
                if(isempty(pp)&isempty(qq))
                    k = 1;
                elseif(islogical(pp)&islogical(qq))
                    if(pp==qq)
                        k = 1;
                    end
                elseif(ischar(pp)&ischar(qq))
                    if(strcmp(pp,qq))
                        k = 1;
                    end
                elseif(isnumeric(pp)&isnumeric(qq))
                    if(pp==qq)
                        k = 1;
                    end
                elseif(isstruct(pp)&isstruct(qq))
                    if(checkArguments(pp,qq))
                        k = 1;
                    end
                elseif(iscell(pp)&iscell(qq))
                    if(checkcell(pp,qq))
                        k = 1;
                    end
                end
                count = count + k;
            end
        end
        % if count is equal to the total number of arguments minus that can
        % be ignored, then return 1
        if(count==(pl-length(Args.UnimportantArgs)))
            n = 1;
        else
            n = 0;
        end
    end
%}
