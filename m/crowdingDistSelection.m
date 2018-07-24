function [selected_xvals,selected_yvals,ind] = crowdingDistSelection(xvals,yvals,num2keep)

narch = length(xvals);
crowdingDist = zeros(narch,1);

%sort by xvals
[sortedX,IX] = sort(xvals);
xMax = max(xvals);
%set distances of first and last to a large number
crowdingDist(IX(1)) = 1000;
crowdingDist(IX(narch)) = 1000;
for i=2:narch-1
    crowdingDist(IX(i)) = abs(sortedX(i+1)-sortedX(i-1))/xMax;
end

%sort by yvals
[sortedY,IY] = sort(yvals);
yMax = max(yvals);
%set distances of first and last to a large number
crowdingDist(IY(1)) = 1000;
crowdingDist(IY(narch)) = 1000;
for i=2:narch-1
    crowdingDist(IY(i)) =crowdingDist(IY(i)) + abs(sortedY(i+1)-sortedY(i-1))/yMax;
end

[~, indCD] = sort(crowdingDist,1,'descend');
ind = indCD(1:num2keep);

selected_xvals = xvals(ind);
selected_yvals = yvals(ind);