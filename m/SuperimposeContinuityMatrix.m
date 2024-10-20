function overall_matrix = SuperimposeContinuityMatrix(matrix0,matrix1)
% main idea is to use cellfun to merge two arrays

% initialize
overall_matrix = cell(size(matrix0));
for i = 1:size(matrix0,1)
    for j = 1:size(matrix0,2)
        overall_matrix(i,j) = java.util.ArrayList;
    end
end

% create new matrix
for i = 1:size(matrix0,1)% for each measurement
    for j = 1:size(matrix0,2)
        overall_matrix{i,j} = matrix0{i,j}.clone();
        if matrix1{i,j}.size>0
            array = matrix1{i,j}.iterator;
            while array.hasNext
                overall_matrix{i,j}.add(array.next());
            end
        end
    end
end