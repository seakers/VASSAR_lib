function SEL_choose_archs_for_local_search()
% global params
r = global_jess_engine();
fact_archs = r.listFacts();
while(fact_archs.hasNext())
    f_arc = fact_archs.next();
    templ = f_arc.getDeftemplate.getName();
    if ~strcmp(templ,'HARD-CONSTRAINTS::SEL-ARCH')
        continue;
    else
%         disp('hola');
        call = ['(modify ' num2str(f_arc.getFactId()) ' (mutate yes))'];
        r.eval(call);
    end
end
end