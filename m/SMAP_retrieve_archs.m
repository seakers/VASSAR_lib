function [arch_str,archs] = SMAP_retrieve_archs()
    r = global_jess_engine;
        
    MAX_ARCHS = 100000;
    MAX_INSTRS = 5;
    archs = zeros(MAX_ARCHS,MAX_INSTRS);
    arch_str = cell(MAX_ARCHS,1);
%     results.instrument_orbits = cell(MAX_ARCHS,1);
    fact_archs = r.listFacts();
    ii = 1;
    while(fact_archs.hasNext())
        f_arc = fact_archs.next();
        templ = f_arc.getDeftemplate.getName();
        if ~strcmp(templ,'MANIFEST::ARCHITECTURE')
            continue;
        else
            
%             for nn = 1:nmetrics
%                 values(ii,nn) = f_arc.getSlotValue(options.values{nn}).floatValue(r.getGlobalContext());
%                 results.(options.values{nn}) = add_el(results.(options.values{nn}),values(ii,nn));
%             end
%             results.instrument_orbits{ii} = jess_value(f_arc.getSlotValue('instrument-orbits'));
            arch_str{ii} = f_arc.toString;
            arc = cell2mat(jess_value(f_arc.getSlotValue('sat-assignments')));
            archs(ii,1:length(arc)) = arc;
            ii = ii + 1;
        end
    end
    archs(ii:end,:) = [];
    arch_str(ii:end) = [];
end