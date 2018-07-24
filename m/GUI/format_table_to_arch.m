function arch = format_table_to_arch(table)
    global params
    nsats = table{5,2};
    mapping = java.util.HashMap;
    for i = 5:5+params.norb-1
        payload = {};
        n=3;
        while(true)
            instr = table{i,n};
            if isempty(instr)
                break;
            end
            payload = [payload instr];
            n=n+1;
        end
        mapping.put(table{i,1},payload)
    end
    arch = rbsa.eoss.Architecture(mapping,str2num(nsats));
    arch.setEval_mode('DEBUG');
end