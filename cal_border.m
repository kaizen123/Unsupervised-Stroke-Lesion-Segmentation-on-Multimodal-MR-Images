function border = cal_border(data_in)
%CAL_BORDER calculate the effective border of input 3-D data
%   border: 1*6 array
% The first two number in border represent the effective border in the
% first dimension, the middle two represent the second dimension, while the
% last two represent the third dimension.

[firstD, otherD] = find(data_in);
[secondD,thirdD] = ind2sub([size(data_in,2),size(data_in,3)],otherD);
border = [min(firstD) max(firstD) min(secondD) max(secondD) min(thirdD) max(thirdD)];

end

