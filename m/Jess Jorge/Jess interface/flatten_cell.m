function c = flatten_cell(c)
    if iscell(c)
        c = cellfun(@flatten_cell, c, 'uniformOutput', false);
        if any(cellfun(@iscell,c))
            c = [c{:}];
        end
    end
end