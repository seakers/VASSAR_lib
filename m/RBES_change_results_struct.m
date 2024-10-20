function results2 = RBES_change_results_struct(results)
    
    if ~iscell(results) && length(results) == 1
        fields = fieldnames(results);
        narc = length(results.(fields{1}));
        results2 = cell(narc,1);
        for i = 1:narc
            for j = 1:length(fields)
                if isnumeric(results.(fields{j}))
                    results2{i}.(fields{j}) = results.(fields{j})(i);
                elseif iscell(results.(fields{j}))
                    results2{i}.(fields{j}) = results.(fields{j}){i};
                end
            end
        end
    else
        fields = fieldnames(results{1});
        narc = length(results);
        for j = 1:length(fields)
            if isscalar(results{1}.(fields{j}))&& isnumeric(results{1}.(fields{j}))
                results2.(fields{j}) = zeros(narc,1);
            else
                results2.(fields{j}) = cell(narc,1);
            end
        end
        for i = 1:narc
            for j = 1:length(fields)
                if isscalar(results{i}.(fields{j})) && isnumeric(results{i}.(fields{j}))
                    results2.(fields{j})(i) = results{i}.(fields{j});
                else
                    results2.(fields{j}){i} = results{i}.(fields{j});
                end
            end
        end
    end
end