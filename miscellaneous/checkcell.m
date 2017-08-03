function n = checkcell(p,q,varargin)
% This function is used for checking if two cell arrays are the same.

count = 0;

if(iscell(p)&&iscell(q))
    pl = length(p);
    ql = length(q);
    if(pl==ql)
        for i = 1:pl
            pp = p{i};
            qq = q{i};
            k = 0;
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
                if(checkcell)
                    k = 1;
                end
            end
            count = count + k;
        end
        if(count==pl)
            n = 1;
        else
            n = 0;
        end
    end
end