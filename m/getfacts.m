function list = getfacts(module,template)
    r = global_jess_engine;
    all = r.listFacts();
    list = java.util.ArrayList;
    while(all.hasNext)
        f = all.next();
        if ~strcmp(f.getName,[module '::' template])
            continue;
        end
        list.add(f);
    end
end
