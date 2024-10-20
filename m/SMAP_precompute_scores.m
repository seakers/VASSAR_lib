function SMAP_precompute_scores()
%% SMAP_precompute_scores.m
%
% This function computes the scores of all subsets of instrument in all
% possible orbits
% scores.get([orbit, subset]) = [facts(),cost]
global scores params
scores = java.util.HashMap;
orbs = params.orbit_list;norb = length(orbs);
instr = params.instrument_list;ninstr = length(instr);
sum = 0;
for i = 1:norb
    orbit = orbs{i};
    for j = 1:2^ninstr-1
        subset = instr(logical(de2bi(j,ninstr)));
        fprintf('Precomputing orb %s subset %s...',orbit,StringArraytoStringWithSpaces(subset));    tic;
        mission = create_test_mission([orbit '-' num2str(j)],subset,2015,5,get_orbit_struct_from_string(orbit));
        RBES_Evaluate_Mission(mission);
        facts = getfacts('REQUIREMENTS','Measurement');
        scores = put_scores(scores,orbit,subset,facts);
        t = toc;
        sum = sum + t/60;
        done = (i-1)*norb + j;
        all = norb*(2^ninstr-1);
        remaining = all - done;
        fprintf('%.1f min elapsed total (%.1f sec for this iter). %.1f min remaining\n',sum,t,remaining*t/60);
    end
end
save scores scores;
end

function scores = put_scores(scores,orbit,subset,facts)
   key = get_key(orbit,subset);
    scores.put(key,facts);
end
