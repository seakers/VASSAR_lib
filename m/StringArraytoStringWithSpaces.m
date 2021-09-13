function str = StringArraytoStringWithSpaces(array)
%% StringArraytoStringWithSpaces.m
% Usage: str = StringArraytoStringWithSpaces(params.instrument_list(diff==-1));
n = length(array);
str = char(array(1));
for j = 2:n
    str = [str ' ' char(array(j))];
end
end