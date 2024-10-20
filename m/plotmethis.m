function [] = plotmethis(sensit_results)
res = sensit_results.entrySet.iterator;
while(res.hasNext())
    one_att = res.next();
    att = one_att.getKey;
    hm = one_att.getValue;
    vals = hm.entrySet.iterator;
    labels = cell(1,hm.entrySet.size);
    values = zeros(1,hm.entrySet.size);
    for i = 1:hm.entrySet.size
        nn = vals.next();
        labels{i} = nn.getKey();
        values(i) = nn.getValue();
    end
    figure;
    bar(values);
    set(gca,'XTickLabel',labels);
    title(att);
end