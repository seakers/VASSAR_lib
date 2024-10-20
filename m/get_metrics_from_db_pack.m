function [sciences,costs,u,archs] = get_metrics_from_db_pack(db_pack)
entries = db_pack.entrySet.iterator;
n = db_pack.size;
sciences = zeros(n,1);
costs = zeros(n,1);
u = zeros(n,1);

archs = cell(n,1);
i = 1;
while(entries.hasNext())
    entry = entries.next();
    archs{i} = entry.getKey;
    metrics = entry.getValue;
    sciences(i) = metrics.get(0);
    costs(i) = metrics.get(1);
    u(i) = metrics.get(2);
    i = i + 1;
end
end