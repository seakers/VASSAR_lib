function combined_matrix = RBES_combine_DC_matrices(dc_matrices)
combined_matrix = dc_matrices{1};
for i = 2:length(dc_matrices)
    combined_matrix = SuperimposeContinuityMatrix(combined_matrix,dc_matrices{i});
end
end