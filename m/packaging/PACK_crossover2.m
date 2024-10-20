function xoverKids  = PACK_crossover2(parents,options,GenomeLength,FitnessFcn,unused,thisPopulation)
%
%

% How many children to produce?
nKids = length(parents)/2;
% Extract information about linear constraints, if any
linCon = options.LinearConstr;
constr = ~isequal(linCon.type,'unconstrained');
% Allocate space for the kids
xoverKids = zeros(nKids,GenomeLength);

% To move through the parents twice as fast as thekids are
% being produced, a separate index for the parents is needed
index = 1;
% for each kid...
for i=1:nKids
    % get parents
    papa = thisPopulation(parents(index),:);
    index = index + 1;

    mama = thisPopulation(parents(index),:);
    index = index + 1;

    %% Compute children from 2 parents in sats form
    first_half = papa(1:ceil(GenomeLength/2));
    first_half_papa = PACK_arch2sats(first_half);%these are length(first_half_papa) sats
    nsat1 = length(first_half_papa);

    second_half =  mama(ceil(GenomeLength/2)+1:end);
    second_half_mama = PACK_arch2sats(PACK_fix(second_half),ceil(GenomeLength/2));
    second_half =  PACK_fix(second_half) + max(first_half);
    
    
    existing_sat = mama(ceil(GenomeLength/2)+1:end) <= max(mama(1:ceil(GenomeLength/2))); %existing_sat(i) = 1 means that instrument i is in a satellite that was created in the first half
    nsat2 = length(second_half_mama);
  
    % Try to combine satellites of second half with satellite of first half
    kid_sat = [first_half_papa;second_half_mama];
    for j = 1:nsat2 % foreach satellite from mum
        sat = second_half_mama{j}; % satellite
        for k = 1:length(sat) % loop through its instruments
            instr = sat(k);% instr
            if existing_sat(instr-ceil(GenomeLength/2)) % if this instrument in mum belongs to a satellite of the 1st half
                % lump this satellite with a random satellite from first half
                % (which comes from dad)
                kid_sat = merge_sats(kid_sat,randi(nsat1),j+nsat1);% merge satellites random and this one
                break;% go to next satellite in loop over j
            end
        end
    end
%     end
    

    xoverKids(i,:) = PACK_fix(PACK_sats2arch(kid_sat));
    
    % Make sure that offspring are feasible w.r.t. linear constraints
    if constr
        feasible  = isTrialFeasible(xoverKids(i,:)',linCon.Aineq,linCon.bineq,linCon.Aeq, ...
            linCon.beq,linCon.lb,linCon.ub,sqrt(options.TolCon));
        if ~feasible % Kid is not feasible
            % Children are arithmetic mean of two parents (feasible w.r.t
            % linear constraints)
            alpha = rand;
            xoverKids(i,:) = round(alpha*thisPopulation(r1,:) + ...
                (1-alpha)*thisPopulation(r2,:));
        end
    end
end

end


