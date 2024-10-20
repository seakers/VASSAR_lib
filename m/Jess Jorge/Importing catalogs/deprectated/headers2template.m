function [] = headers2template(name, headers)
% Creates the template named Row in the Rete object j.
% Columns named 'discard' are skipped.

    nil = jess.Funcall.NIL;
    j = global_jess_engine();

    template = jess.Deftemplate(name, '', j);
    for i = 1:length(headers)
        headers{i} = jess_symbol(headers{i});
        
        if strcmp(headers{i}, 'discard'), continue; end
        
        template.addSlot(headers{i}, nil, 'ANY');
            % if you get the error "no function with such signature"
            % here, check your xlsread isn't feeding you extra columns
            % with NaNs. To remove them, go to the excel file, select a
            % bunch of columns next to your data and *delete* them
            % (erasing won't work).
    end        
    j.addDeftemplate(template);
end