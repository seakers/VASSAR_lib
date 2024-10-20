function [x,fval,exitflag,output,population,score] = gaMultiObjPareto()
% This is an auto generated M-file from Optimization Tool.  (At least
% originally... -ds)
load gaInputs.mat
nvars = numMissions;
% SIDE NOTE: After this is done, get scores to be positive again and then look
% at them using the 'plotmatrix' function.

% Start with the default options
options = gaoptimset;

% Use a custom population type because we are using a population of
% permutations of the sequence 1 .. 38.
options = gaoptimset(options, 'PopulationType' , 'custom');

% These functions were taken from the example code from the 'traveling
% salesman' GA demo inside MATLAB.  This was done because that demo also
% minimizing a permutation by choosing the order in which nodes are
% visited.  See that demo to better understand what is going on.  

options = gaoptimset(options, 'CreationFcn',     @createPermutations);
options = gaoptimset(options, 'SelectionFcn' ,   {  @selectiontournament [] });
options = gaoptimset(options, 'CrossoverFcn' ,   @crossoverPermutation);
options = gaoptimset(options, 'MutationFcn' ,    @mutatePermutation);
options = gaoptimset(options, 'PlotFcns',@gaplotrange);

% Before I found out about the Traveling Salesman demo, 
% I also implemented versions of these functions,
% but have not tested my own versions.  There is ample literature that can
% be found online describing multiple methods for doing Crossover and
% Mutation functions on permutations or orderings.
% See "Genetic Algorithms and Engineering Optimization" by Gen and Cheng in
% section 6.2.3 for adapted crossover operators.  (Can be found online in
% Google books with some searching.)
% See partially mapped crossover PMX, order crossover OX, position-based
% crossover, order-based crossover, cycle-crossover CX.

options = gaoptimset(options, 'Display' ,        'iter');

% I kicked these variables up very high, causing simulation to run all
% night with values of 500 and 1000.  Results may vary given different
% values.  Test it out yourself to see what works.
options = gaoptimset(options, 'Generations',     50);
options = gaoptimset(options, 'PopulationSize',  100);

% This option would be nice, but is not legal given our strucutre.
% options = gaoptimset(options, 'Vectorized', 'on');

% Now call the multivariable optimization function with all the GA functions 
% and the utility function. 
[x,fval,exitflag,output,population,score] = ...
gamultiobj(@getUtilities,nvars,[],[],[],[],[],[],options);

