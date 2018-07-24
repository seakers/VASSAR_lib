function [x,fval,exitflag,output,population,score] = gaMultiObjPareto(nvars)
N_INSTR = nvars;
options = gaoptimset;
options = gaoptimset(options, 'PopulationType' , 'doubleVector');
options = gaoptimset(options, 'CreationFcn',     @EO_create_funct);
% options = gaoptimset(options, 'SelectionFcn' ,   {  @selectiontournament [] });
options = gaoptimset(options, 'CrossoverFcn' ,   @EO_crossover);
options = gaoptimset(options, 'MutationFcn' ,    @EO_mutation);
options = gaoptimset('PlotFcns',@gaplotpareto);
% options = gaoptimset(options, 'Display' ,        'iter');
options = gaoptimset(options, 'Generations',     50);
options = gaoptimset(options, 'PopulationSize',  20);
init_pop = create_init_pop(20,N_INSTR);
options = gaoptimset(options, 'InitialPopulation',  init_pop);

% A = [eye(N_INSTR); -eye(N_INSTR)];
% b = [N_INSTR.*ones(N_INSTR,1);-1.*ones(N_INSTR,1)];
A = [];
b = [];

[x,fval,exitflag,output,population,score] = ...
gamultiobj(@EO_fitness_fcn_multi,nvars,A,b,[],[],[],[],options);

