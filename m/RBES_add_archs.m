function [archs2,results2] = RBES_add_archs(archs_to_add,results,archs)
global params
archs2 = archs;
results2 = results;
narc = size(archs_to_add,1);
for i = 1:narc
    arc = archs_to_add(i,:);
    if strcmp(params.MODE,'PACKAGING')
        resu2 = PACK_evaluate_architecture8(arc);
    end
    add = resu2;
    add.instrument_orbits = resu2.orbits;
    add = rmfield(add,{'panel_scores','combined_subobjectives','data_continuity','launch_dates','orbits'});
    add.arch = arc;
    
    [archs2,results2] = RBES_add_arch(add,results2,archs2);
end

end
