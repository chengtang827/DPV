function r = plus(p,q,varargin)
%@dirfiles/plus Overloaded plus function for dirfiles objects.
%   R = plus(P,Q) combines dirfiles objects P and Q and returns the
%   dirfiles object R.

% % get name of class
% classname = mfilename('class');
% 
% % check if first input is the right kind of object
% if(~isa(p,classname))
% 	% check if second input is the right kind of object
% 	if(~isa(q,classname))
% 		% both inputs are not the right kind of object so create empty
% 		% object and return it
% 		r = feval(classname);
% 	else
% 		% second input is the right kind of object so return that
% 		r = q;
% 	end
% else
% 	if(~isa(q,classname))
% 		% p is the right kind of object but q is not so just return p
% 		r = p;
%     elseif(isempty(p))
%         % p is right object but is empty so return q, which should be
%         % right object
%         r = q;
%     elseif(isempty(q))
%         % p are q are both right objects but q is empty while p is not
%         % so return p
%         r = p;
% 	else
% 		% both p and q are the right kind of objects so add them 
% 		% together
% 		% assign p to r so that we can be sure we are returning the right
% 		% object
% 		r = p;
% 		% useful fields for most objects
% 		r.data.numSets = p.data.numSets + q.data.numSets;
% 
% 		
% 		% object specific fields
% 		r.data.dlist = [p.data.dlist; q.data.dlist];
% 		r.data.setIndex = [p.data.setIndex; (p.data.setIndex(end) ...
% 			+ q.data.setIndex(2:end))];
% 			
% 		% add nptdata objects as well
% 		r.nptdata = plus(p.nptdata,q.nptdata);
% 	end
% end

% check for empty object
if(isempty(q.data))
	r = p;
elseif(isempty(p.data))
	r = q;
else
    r=p;
 	r.data.numSets = p.data.numSets + q.data.numSets;
    r.data.setNames = [r.data.setNames; q.data.setNames];
    r.data.original = [r.data.original; q.data.original];
    r.data.dilateRC = [r.data.dilateRC; q.data.dilateRC];
    r.data.limit = [r.data.limit; q.data.limit];
    r.data.protectedRC = [r.data.protectedRC; q.data.protectedRC];
    
    if(isempty(r.data.fr))
        r.data.fr = q.data.fr;
    else
        if(isempty(q.data.fr))
            
        else
            r.data.fr = concat(r.data.fr, q.data.fr);
        end
    end

    if(isempty(r.data.output1))
        r.data.output1 = q.data.output1;
    else
        if(isempty(q.data.output1))
            
        else
            r.data.output1 = concat(r.data.output1, q.data.output1);
        end
    end
    
    if(isempty(r.data.output2))
        r.data.output2 = q.data.output2;
    else
        if(isempty(q.data.output2))
            
        else
            r.data.output2 = concat(r.data.output2, q.data.output2);
        end
    end
    
    if(isempty(r.data.output3))
        r.data.output3 = q.data.output3;
    else
        if(isempty(q.data.output3))
            
        else
            r.data.output3 = concat(r.data.output3, q.data.output3);
        end
    end
    
        
%     if (size(r.data.fr)>0)
%         if (size(q.data.fr)>0)
%             r.data.fr = concat(r.data.fr, q.data.fr);
%         end
%     else
%         r.data.fr = q.data.fr;
%     end
    
    r.nptdata = plus(p.nptdata,q.nptdata);
end


    
        