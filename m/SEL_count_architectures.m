function N = SEL_count_architectures()
%% SEL_count_architectures.m
r = global_jess_engine();
fact_archs = r.listFacts();
ii = 0;
while(fact_archs.hasNext())
    f_arc = fact_archs.next();
    templ = f_arc.getDeftemplate.getName();
    if ~strcmp(templ,'HARD-CONSTRAINTS::SEL-ARCH')
        continue;
    else
        ii = ii + 1;
    end
end
N = ii;
end