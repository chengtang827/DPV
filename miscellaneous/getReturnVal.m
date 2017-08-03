function rv = getReturnVal(ReVal, ReValVal)

rvarl = length(ReVal);
if(rvarl>0)
     % assign requested variables to varargout
     for rvi = 1:rvarl
         rv{1}{rvi*2-1} = ReVal{rvi};
         rv{1}{rvi*2} = ReValVal{rvi};
     end
end