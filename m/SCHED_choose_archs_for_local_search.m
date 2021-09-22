function SCHED_choose_archs_for_local_search()
% global params
r = global_jess_engine();
fact_archs = r.listFacts();
PARAM = RBES_get_parameter('mutation_improvement_ratio');
u = 0.25;
while(fact_archs.hasNext())
    f_arc = fact_archs.next();
    templ = f_arc.getDeftemplate.getName();
    if ~strcmp(templ,'HARD-CONSTRAINTS::PERMUTING-ARCH')
        continue;
    else
%         u = rand;
        u = 1 - u;% alternate
        if u<PARAM % mutation
            call = ['(modify ' num2str(f_arc.getFactId()) ' (mutate yes) (improve no))'];
            r.eval(call);
            
        else % improvement
            call = ['(modify ' num2str(f_arc.getFactId()) ' (mutate no) (improve yes))'];
            r.eval(call);
        end
    end
end
end