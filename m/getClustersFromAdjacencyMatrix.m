function assig = getClustersFromAdjacencyMatrix(M)
%% getClustersFromAdjacencyMatrix.m
% computes clusters from symmetric (square) adjacency matrix
n = size(M,1);

assig = zeros(1,n);%  assig(i) = j if  element i is assigned to set j
tmp = find(M(1,:)==1);%2,3 means that 1 is connected to 2 and 3
assig([1 tmp]) = 1;
for i = 2:n
    tmp  = find(M(i,i+1:end)==1);
    vec = [i tmp + i];
    found = false;
    for j = 1 :length(vec)
        if (assig(vec(j))>0)
            assig([i tmp+i]) = assig(vec(j));
            found = true;
            break;
        end
    end
    if found == false
        assig([i tmp+i]) = max(assig) + 1;
    end
end
end
