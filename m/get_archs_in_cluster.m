function indexes = get_archs_in_cluster(archs,results,bounds)
    nmet = length(bounds)/2;
    metrics = fields(results);
    values = cell(nmet,1);
    indexes = true(length(archs),1);
    for i = 1:nmet
        values{i} = results.(metrics{i});
        indexes = indexes & values{i} > bounds(2*i-1) & values{i} < bounds(2*i);
    end
end