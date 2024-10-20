%% IEEE14_KISA_exp_search_java.m
% global params
% 
% % RBES_f('C:\Users\dani\Documents\My Dropbox\EOCubesats\RBES_Cubesats3');
% 
% %% Initialization
% RBES_Init_Params_Cubesats('SELECTION');
% RBES_Init_WithRules;
% 

% %% Off-line computations
% % EOCubesats_precompute_scores;
% load scores;
% % EOCubesats_precompute_revtimes;
% load revtimes;
% % min max
% 
% % Compute min and max for normalization
% tmp = RBES_Evaluate_Cubesat_Manifest(zeros(1,ninstr*norb),params);
% params.min_cost = tmp(2);
% params.min_science = tmp(1);
% 
% tmp = RBES_Evaluate_Cubesat_Manifest(ones(1,ninstr*norb),params);
% params.max_science = tmp(1);
% params.max_cost = tmp(2);
%
import rbsa.eoss.*;
import rbsa.eoss.smap.*;
params = Params('C:\\Users\\Dani\\My Documents\\My Dropbox\\RBES SMAP for IEEEAero14','CRISP','test');%C:\\Users\\Ana-Dani\\Dropbox\\EOCubesats\\RBES_Cubesats7" OR C:\\Users\\dani\\My Documents\\My Dropbox\\EOCubesats\\RBES_Cubesats7
ninstr =params.ninstr;
norb = params.norb;
nvars = ninstr*norb;
ArchEval = ArchitectureEvaluator.getInstance;
ArchEval.init( 1 );
ArchEval.evalMinMax;
% arch = Architecture(true(1,nvars),norb,ninstr);
% % arch.setEval_mode('DEBUG');
% r2 = ArchEval.evaluateArchitectureFast(arch);
% ArchEval.clearResults;
% 
% arch = Architecture(false(1,nvars),norb,ninstr);
% r1 = ArchEval.evaluateArchitectureFast(arch);
ArchEval.clearResults;

% params.min_science = -r1.getScience;
% params.min_cost = r1.getCost;
% params.max_science = -r2.getScience;
% params.max_cost = r2.getCost;

%% MOGA 
% GA options

options = gaoptimset;
options = gaoptimset(options, 'PopulationType' , 'bitString');
options = gaoptimset(options,'PlotFcns',@gaplotpareto);
options = gaoptimset(options, 'Display' ,        'iter');
options = gaoptimset(options, 'Generations',     10);
options = gaoptimset(options, 'PopulationSize',  [4*nvars]);
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
[x,fval,exitflag,output,population,score] = gamultiobj(@(x)RBSA_EOSS_SMAP_fitness_function(x,params),nvars,[],[],[],[],[],[],options);

% Save results
t = clock();
filename = ['EOCubesats2-GA-' date '-' num2str(t(4)) '-' num2str(t(5))];  
save(filename,'x','fval','population');

close all;
EOCubesats_plot_pareto_front(x,fval);

%% Local Search
pop = Population(logical(x));
archs = pop.getArchs_list;
ag = ArchitectureGenerator.getInstance;
tmp = ag.localSearch(archs);
newpop = Population(tmp);
pop2 = newpop.getBool_mat;
javaMethod('setPopulation',ArchEval,pop2, params.norb, params.ninstr);
ArchEval.evaluatePopulation;
results = ArchEval.getResults;
% pareto filter
x2 = false(results.size,nvars);
fval2 = zeros(results.size,2);
for i = 1:results.size
    res = results.pop;
    ar = res.getArch;
    x2(i,:) = ar.getBitString';
    fval2(i,1) = res.getScience;
    fval2(i,2) = res.getCost;  
end
fval2(:,1) = (-fval2(:,1)+params.min_science)./(params.min_science-params.max_science);
fval2(:,2) = (fval2(:,2)-params.min_cost)./(params.max_cost - params.min_cost);
front = paretofront(fval2);
x3 = x2(front,:);
fval3 = fval2(front,:);
ArchEval.clearResults;
filename = ['EOCubesats2-GA-local-search-' date '-' num2str(t(4)) '-' num2str(t(5))];  
save(filename,'x','fval','x3','fval3');

%% Fuzzy scores on pareto frontier
uniquex = unique(x3,'rows');
pop = Population(logical(x3));
archs = pop.getArchs_list;
ag = ArchitectureGenerator.getInstance;


javaMethod('setPopulation',ArchEval,pop.getBool_mat, params.norb, params.ninstr);
ArchEval.evaluatePopulationFuzzy;
results = ArchEval.getResults;

narchs = size(x3,1);
fuzzy_scores = cell(narchs,1);
fuzzy_costs = cell(narchs,1);
for i = 1:narchs
    result = results.pop;
    fuzzy_scores{i} = result.getFuzzy_science;
    fuzzy_costs{i} = result.getFuzzy_cost;
end
plot_fuzzy_vars(fuzzy_scores,fuzzy_costs);
ArchEval.clearResults;
filename = ['EOCubesats2-GA-local-search-fuzzy-' date '-' num2str(t(4)) '-' num2str(t(5))];  
save(filename,'x3','fval3','fuzzy_scores','fuzzy_costs');
% [fuzzy_scores,fuzzy_costs] = RBES_fuzzy_scores(uniquex);
% index = input('Choose an architecture for detailed design ([1-N]): ');
% arch = uniquex(index,:);

%% Detailed analysis on best architecture
% [detailed_design] = EOCubesat_detailed_design(arch);
% filename = ['EOCubesats2-ALL-' date '-' num2str(t(4)) '-' num2str(t(5))];  
% save(filename,'x','fval','output','params','options','population','scores','detailed_design','fuzzy_scores','fuzzy_costs');