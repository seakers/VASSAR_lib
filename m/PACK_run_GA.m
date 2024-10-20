function [x,fval,exitflag,output,population,score] = PACK_run_GA(hObject,MAXSATS)
handles = guidata(hObject); 
nvars = length(handles.params.instrument_list);
options = gaoptimset;
options = gaoptimset(options, 'PopulationType' , 'doubleVector');
% options = gaoptimset(options, 'CreationFcn',     @PACK_create);
% options = gaoptimset(options, 'SelectionFcn' ,   {  @selectiontournament [] });
% options = gaoptimset(options, 'CrossoverFcn' ,   @PACK_crossover);
% options = gaoptimset(options, 'MutationFcn' ,    @PACK_mutation);
% options = gaoptimset('PlotFcns',@PACK_ga_plot);
options = gaoptimset(options, 'Display' ,        'iter');
options = gaoptimset(options, 'Generations',     10);
options = gaoptimset(options, 'PopulationSize',  str2double(get(handles.num_archs,'String')));
% options = gaoptimset(options, 'InitialPopulation',  init_pop);


A = [];
b = [];
% [x,fval,exitflag,output,population,score] = ...
% gamultiobj(@(x)PACK_fitness_fcn_multi(x,r,params),nvars,A,b,[],[],[],[],1:nvars,options);
[x,fval,exitflag,output,population,score] = ...
ga(@(x)PACK_fitness_fcn(x,hObject),nvars,A,b,[],[],ones(1,nvars),MAXSATS.*ones(1,nvars),[],1:nvars,options);

