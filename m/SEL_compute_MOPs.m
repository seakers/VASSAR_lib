%% SEL_compute_MOPs.m
function MOPs = SEL_compute_MOPs(results,archs,weights)

% relative ranking of ref architecture
ref = RBES_get_parameter('ref_sel_arch');
ref_sci = ref.science;
ref_cost = ref.cost;
ref_risk = SEL_compute_programmatic_risk(ref.arch);
ref_fair = 0; % for now

narc = size(archs,1);
results2 = results;

results2.sciences(end+1) = ref_sci;
results2.costs(end+1) = ref_cost;
results2.programmatic_risks(end+1) = ref_risk;
results2.fairness(end+1) = ref_fair;

MOPs.utilities = RBES_compute_utilities2(results2,weights);
[sorted_us,arch_order] = sort(MOPs.utilities,'descend');
MOPs.rank = find(arch_order == narc + 1);


% distance of top architectures to ref architectures
MOPs.distances = SEL_compute_distances_to_ref(archs);
figure;hist(MOPs.distances);

% relative frequency of instruments in top architecture
MOPs.pctgs = SEL_compute_pctg_archs_with_instr(archs);
figure;bar(MOPs.pctgs);
end