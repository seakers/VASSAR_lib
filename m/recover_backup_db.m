%% recover_backup_db.m
function [] = recover_backup_db(filename)
load(filename)
sciences = NUM_sciences;
costs = NUM_costs;
archs = NUM_archs;

narchs = length(archs);
for j = 1:narchs
    good_pack_archs{j}.arch = archs{j};
    good_pack_archs{j}.science = sciences(j);
    good_pack_archs{j}.cost = costs(j);
end
weight_cost = 1;
u_science = (sciences - min(sciences))./(max(sciences)- min(sciences));
au_cost = (costs - min(costs))./(max(costs)- min(costs));% negative utility
utilities = (u_science + weight_cost*(1-au_cost))/(1+weight_cost);
save('good_pack_archs.mat','good_pack_archs','sciences','costs','utilities');