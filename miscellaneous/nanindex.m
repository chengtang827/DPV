function r = nanindex(m,idx,varargin)
%nanindex Access matrix using indices containing NaN's
%   R = nanindex(M,IDX) returns the values specified in IDX, even
%   if IDX contains NaN's.
%
%   R = nanindex(M,IDX,'NanValue',VAL) uses VAL instead of NaN's. 
%      e.g. r = nanindex(sc,tuning,'NanValue',0);

Args = struct('NanValue',nan);
Args = getOptArgs(varargin,Args);

% get entries that are NaN's
if(isnan(Args.NanValue))
    nanidx = find(isnan(idx));
else
    nanidx = find(idx==Args.NanValue);
end
% replace nan with 1
idx(nanidx) = 1;
% use index to get values
r = m(idx);
% put NaN's back
r(nanidx) = Args.NanValue;
