function matrix = ArrayListofArrayList2Matrix(al_of_al)
    
    nrow = al_of_al.size;
    matrix = cell(nrow,1);
    for i = 1:nrow
        al = al_of_al.get(i-1);
        ncol = al.size;
        vector = zeros(1,ncol);
        for j = 1:ncol
            el = al.get(j-1);
            vector(j) = el;
        end
        matrix{i} = vector;
    end
    
end