function pop = createPermutations(NVARS,FitnessFcn,options,params)
%CREATE_PERMUTATIONS Creates a population of permutations.
%   POP = CREATE_PERMUTATION(NVARS,FITNESSFCN,OPTIONS) creates a population
%  of permutations POP each with a length of NVARS. 
%
%   The arguments to the function are 
%     NVARS: Number of variables 
%     FITNESSFCN: Fitness function 
%     OPTIONS: Options structure used by the GA

%   Copyright 2004-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2007/06/14 05:06:18 $

totalPopulationSize = sum(options.PopulationSize);
n = NVARS;
pop = cell(totalPopulationSize,1);
for i = 1:totalPopulationSize
%     pop{i} = randperm(n);
    not_done = true;
    while not_done
        pop{i} = randi([1 params.NumberOfMissions],1,n);
        if length(unique(pop{i}))==n
            not_done = false;
        end
    end
end

%% Force inclusion of initial population
% if ~isempty(params.good_sched_archs)
%     n = length(params.good_sched_archs);
%     for i = totalPopulationSize - n + 1:totalPopulationSize
%         pop(i) = params.good_sched_archs{i-totalPopulationSize+n};
%     end
% end
end