%% IEEE14_KISA_exp_search.m
%% Setup
RBES_f('C:\Users\dani\Documents\My Dropbox\RBES SMAP for IEEEAero14');
RBES_Init_Params_SMAP('PACKAGING');
RBES_Init_WithRules;

%% Full factorial (for true pareto front/best)
% FF Enum
jess reset;
jess assert (MANIFEST::ARCHITECTURE (num-instruments 0) (doesnt-fly (get-instruments)));
jess focus ENUMERATION;
jess run;
archs = SMAP_retrieve_archs();

%FF Eval
results = SMAP_eval_archs(archs);

sciences = results.sciences;
costs = results.costs;
pareto_ranks = RBES_compute_pareto_rankings([-sciences costs],7);
utilities = RBES_compute_utilities3(results,{'sciences','costs'},{'LIB','SIB'},[0.5 0.5]);

% FF save
save_results(results,archs,'IEEE14_KISA','exp_search');

% FF plot
scatter(sciences,costs,'ButtonDownFcn',{@sensitive_plot,archs,sciences,costs,utilities,pareto_ranks});
grid on;
xlabel('Science score','Fontsize',18);
ylabel('Cost estimate ($M)','Fontsize',18);

%% Genetic algorithm
% GA options

options = gaoptimset;
options = gaoptimset(options, 'PopulationType' , 'bitString');
options = gaoptimset(options,'PlotFcns',@gaplotpareto);
options = gaoptimset(options, 'Display' ,        'iter');
options = gaoptimset(options, 'Generations',     250);
options = gaoptimset(options, 'PopulationSize',  [20*nvars]);
options = gaoptimset(options,'TolFun',1e-4,'StallGenLimit',150);
options = gaoptimset(options,'DistanceMeasureFcn',{@distancecrowding,'genotype'});
options = gaoptimset(options, 'ParetoFraction',     0.5);
options = gaoptimset(options, 'CrossoverFraction',     0.6);
options = gaoptimset(options, 'Vectorized','on');

% load('EOCubesats2-20-Jun-2013-17-2.mat');cumul gen: 10
% init_pop = EOCubesat_init_pop(x);
% init_pop = population;
% options = gaoptimset(options, 'InitialPopulation',  init_pop);

% Call GA
clc;
[x,fval,exitflag,output,population,score] = gamultiobj(@(x)IEEE14_KISA_exp_search_fitness_function(x,params),nvars,[],[],[],[],[],[],options);
%% 


