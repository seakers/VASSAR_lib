%% script_error_bars.m
function [err_bars] = script_error_bars(instr)
filename = ['sensit_results_' instr];
load(filename);
res = sensit_results.entrySet.iterator;
minim = Inf;
maxim = 0;
while(res.hasNext()) % for each attribute
    one_att = res.next();
    att = one_att.getKey;
    hm = one_att.getValue;
    vals = hm.entrySet.iterator;
    labels = cell(1,hm.entrySet.size);
    values = zeros(1,hm.entrySet.size);
    
    for i = 1:hm.entrySet.size % for each value
        nn = vals.next();
        labels{i} = nn.getKey();
        fprintf('%s\n',labels{i});
        values(i) = nn.getValue();
    end
    minim = min(minim,min(values));
    maxim = max(maxim,max(values));
end
err_bars = [minim maxim];
end