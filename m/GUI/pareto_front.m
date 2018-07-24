function [x_pareto y_pareto i_pareto i_dominated] =  pareto_front(data, obj)
k = 1;
i_dominated = [];

for arch_i = 1 : size(data,1)
    for arch_j = 1 : size(data,1)
        
        count_i = 0;
        count_j = 0;
        
        for dec = 1:size(obj,2)
            
            if((strcmp(obj(dec), 'SIB')))
                if(data(arch_i, dec) > data(arch_j, dec))
                    count_j = count_j + 1;
                elseif(data(arch_i, dec) < data(arch_j, dec))
                    count_i = count_i + 1;
                end
            elseif (strcmp(obj(dec), 'LIB'))
                if(data(arch_i, dec) < data(arch_j, dec))
                    count_j = count_j + 1;
                elseif(data(arch_i, dec) > data(arch_j, dec))
                    count_i = count_i + 1;
                end
            end
        end
        
        if (count_i == 0 && count_j > 0)
            i_dominated(k) = arch_i;
            k = k+1;
        end
        
    end
    
end

i_dominated = unique(i_dominated);
i_pareto = setdiff(1:1:size(data,1),i_dominated);

% get the pareto frontier points
x_pareto = data(i_pareto,1);
y_pareto = data(i_pareto,2);

% Order the pareto frontier points
[x_pareto,I]=sort(x_pareto');
x_pareto = x_pareto';
y_pareto= y_pareto(I);