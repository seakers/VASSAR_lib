%% RBES_evaluate_instrument_sets
function [archs,results] = RBES_evaluate_instrument_sets()
global params
all = params.instrument_list;
n = length(all);
seq = 1:2^n-1;
if strcmp(params.CASE_STUDY,'IRIDIUM')
    orbit = get_Iridium_orbit();
else
    orbit = [];
end
scores = zeros(2^n-1,1);
NR = [1000 0 8000 1000 0 1000 8000 5000];
RC = [110 85 100 100 60 100 100 100];
cost_vec = NR + 66.*RC;
costs = zeros(2^n-1,1);
fairness = zeros(2^n-1,1);
risks = zeros(2^n-1,1);

archs = zeros(2^n-1,n);
for i = 1:length(seq)
    arch = de2bi(seq(i),n);
    archs(i,:) = arch;
    fprintf('Evaluating arch %d: %s...',seq(i),SEL_arch_to_str(arch));
    list = all(logical(arch));
    mission = create_test_mission('test',list,params.startdate,params.lifetime,orbit);
    [scores(i),panel_score,objective_scor,subobjective_scor2,data_continuity_score,data_continuity_matrix,cos] = RBES_Evaluate_Mission(mission);
    if strcmp(params.CASE_STUDY,'IRIDIUM')
        costs(i) = cost_vec*arch'/1000;
    else
        costs(i) = cos;
    end
    fairness(i) = min(panel_score);
    risks(i) = SEL_compute_programmatic_risk(arch);
    fprintf('...science = %f, cost = %f, risk = %f, fairness = %f\n',scores(i),costs(i),risks(i),fairness(i))
    if isequal(arch,params.ref_sel_arch.arch)
        params.ref_sel_arch.science = scores(i);
        params.ref_sel_arch.cost = costs(i);
        params.ref_sel_arch.programmatic_risk = risks(i);
        params.ref_sel_arch.fairness = fairness(i);
    end
end
results.sciences = scores;
results.costs = costs;
results.programmatic_risks = risks;
results.fairness = fairness;
results.utilities = RBES_compute_utilities3(results,{'sciences','costs','programmatic_risks'},{'LIB','SIB','SIB'},[0.4 0.4 0.20]);
results.pareto_rankings = RBES_compute_pareto_rankings([-scores costs]);
[bool,fit] = SEL_Iridium_archs_that_fit(archs,[1 0 0 1 0 1 1 1],2);
results.fits = fit;
%% Plot
f = figure;
ax = axes('Parent',f,'FontSize',11);
pareto_rankings = RBES_compute_pareto_rankings([-scores costs],3);
front = pareto_rankings<2;
fr = plot(scores(front),costs(front),'gd','MarkerSize',12,'MarkerFaceColor','g','Parent',ax);
hold on;
dom = plot(scores,costs,'bd','MarkerSize',8,'MarkerFaceColor','b','Parent',ax);
xlabel('Scientific scores','FontSize',11);
ylabel('Development costs ($M)','FontSize',11);
title('Science vs costs for all possible instrument sets','FontSize',11);
grid on;
savepath = [params.path_save_results 'selection\'];
tmp = clock();
hour = num2str(tmp(4));
minu = num2str(tmp(5));
filesave = [savepath 'SEL--instrument-sets-science-vs-cost-' date '-' hour '-' minu '.emf'];
print('-dmeta',filesave);
filesave = [savepath 'SEL--instrument-sets-science-vs-cost-' date '-' hour '-' minu '.mat'];
save(filesave,'archs','results');
end