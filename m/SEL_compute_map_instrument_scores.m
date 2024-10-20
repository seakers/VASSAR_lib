%% SEL_compute_map_instrument_scores.m
% This function evaluates for each instrument, 4 different architectures:
% a single satellite carrying one copy, and then constellations carrying 2,
% 3, and 4 copies in different planes.
% Assume params structure has been created

% Clear expl facility
clear explanation_facility

instr_list = params.instrument_list;
ni = length(instr_list); % number of instruments (total)

for i = 1:ni
    for n = 1:4
        call = ['(assert (MANIFEST::Mission (Name ' instr_list{i} num2str(n) ' )' ...
                ' (instruments ' instr_list{i} ')' ...
                ' (lifetime ' num2str(params.lifetime) ')' ...
                ' (launch-date 2015)' ...
                '))'];
        r.eval(call);
    end
end

%% Evaluate asserted missions
science_results = RBES_Evaluate_Manifest(r,params);


end