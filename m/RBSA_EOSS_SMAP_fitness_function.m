function fitness = RBSA_EOSS_SMAP_fitness_function(population,params)

    ArchEval = rbsa.eoss.ArchitectureEvaluator.getInstance;
    javaMethod('setPopulation',ArchEval,logical(population), params.norb, params.ninstr);
    ArchEval.evaluatePopulation;
    results = ArchEval.getResults;
    narch = results.size;
    its = 1;
    while narch < size(population,1) && its < 5
        fprintf('Narchs = %d, pop = %d, waiting 5 seconds (%d)\n',narchs,size(population,1),its);
        pause(5);
        narch = results.size;
        its = its+1;
    end
    unsorted_fitness = zeros(narch,2);
    archs = false(narch,params.norb*params.ninstr);
    for i = 1:narch
        res = results.pop;
        if isempty( res )
            hola = 0;
        end
        ar = res.getArch;
        archs(i,:) = ar.getBitString';
        unsorted_fitness(i,1) = res.getScience;
        unsorted_fitness(i,2) = res.getCost;
    end
    fitness = sort_vector(population,archs,unsorted_fitness);
    ArchEval.clearResults;
    if isempty(params.min_science) || isempty(params.min_cost) || isempty(params.max_science) || isempty(params.max_cost) 
    fitness(:,1) = -fitness(:,1);
%     fitness(:,2) = total_cost;
else
    fitness(:,1) = (-fitness(:,1)+params.min_science)./(params.min_science-params.max_science);
    fitness(:,2) = (fitness(:,2)-params.min_cost)./(params.max_cost - params.min_cost);
    end

end
