function res = eval_this()
    global params AE
    mapping = java.util.HashMap;
    theorbits = cell(params.orbit_list);
    theinstruments = cell(params.instrument_list);
    for o = 1:params.norb
        orb = theorbits{o};
        valid = false;
        while(~valid)
            tmp = input(['Payload in orb ' orb ' ? '],'s');
            if isempty(tmp)
                instruments = {};
                break;
            end
            tmp2 = strsplit(tmp,' ');
            if ~iscell(tmp2)
                instruments{1} = tmp;
            else
                instruments = tmp2;
            end
            valid = true;
            for i = 1:length(instruments)
                if sum(cellfun(@(x)strcmp(x,instruments{i}),theinstruments))==0
                    valid = false;
                    break;
                end
            end
        end
        mapping.put(orb,instruments);
    end
    arch = rbsa.eoss.Architecture(mapping);
    res = AE.evaluateArchitecture(arch,'Fast');
    fprintf('%s\n',char(res.toString));
end
