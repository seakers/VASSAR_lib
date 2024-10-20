function matrix1 = OffsetContinuityMatrix(matrix0,lifetime,launchdate)
%% OffsetContinuityMatrix.m
% This function takes a continuity matrix that is calculated with a
% launchdate = startdate and an arbitrary lifetime, and creates a new
% continuity matrix matrix1 that is identical to matrix0 except that it
% starts in launchdate and has a lifetime of lifetime years.
% In order to do so, it takes 
global params
if isjava(matrix0)
    matrix0 = cell(matrix0);
end

% compute  lifetime
life = round(lifetime/params.timestep);%lifetime in indexes

% compute offset
launch = max(1,round((launchdate-params.startdate)/params.timestep));%launch in indexes

% initialize
matrix1 = cell(size(matrix0));
for i = 1:size(matrix0,1)
    for j = 1:size(matrix0,2)
        matrix1(i,j) = java.util.ArrayList;
    end
end

% create new matrix
sizes = cellfun(@size,matrix0);
indexes1 = find(sum(sizes,2)>0);
indexes2 = max(1,launch):min(size(matrix0,2),launch+life);
for i = 1:length(indexes1)% for each measurement
    for j = 1:length(indexes2)
        matrix1{indexes1(i),indexes2(j)} = matrix0{indexes1(i),j}.clone();%any column of matrix 0 will do
    end
end

end