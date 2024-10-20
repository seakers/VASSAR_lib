function [] = row2fact(name, headers, row)
% Asserts a Row fact corresponding to the given row in the Rete object j.
% Values whose header is 'discard' are skipped.
    j = global_jess_engine();
    f = jess.Fact(name, j);
    for i = 1:length(headers)                
        if strcmp(headers{i}, 'discard'), continue; end
        f.setSlotValue(headers{i}, excel2jessValue(row{i}));
    end
    j.assertFact(f);
end