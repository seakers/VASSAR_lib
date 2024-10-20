%% Evaluate_Iridium_architecture.m
function [r,score,panel_scores,data_continuity_score,params] = Evaluate_Iridium_architecture(r,arch,params)
% Usage : [r,score_vec,panel_scores_mat,data_continuity_score_vec] = Evaluate_Iridium_architecture(r,arch,params)
% arch is a row vector of 66 integers. Each integer represents a payload
% id. The correspondance is given in  params.payload_list
clear explanation_facility
r.reset;
params.number_of_missions = 0;
%% Assert one Mission per satellite
for i = 1:length(arch)
    if arch(i) >0
        params.number_of_missions = params.number_of_missions + 1;
        % Retrieve instrument names
        instr_list_str = [];
        n = length(params.payload_list{arch(i)}.instruments);

        for j = 1:n
            instr_list_str = [instr_list_str ' ' params.payload_list{arch(i)}.instruments{j}];
        end

        % Retrieve orbital parameters
        vars = params.IridiumSatelliteParameters.get(i).toArray;% [raan, ano, launchdate]
        call = ['(assert (MANIFEST::Mission (Name ' params.satellite_names '-' num2str(i) ')' ...
            ' (orbit-altitude# ' num2str(params.Iridium_altitude) ')' ...
            ' (orbit-inclination ' num2str(params.Iridium_inclination) ')' ...
            ' (orbit-RAAN ' num2str(vars(1)) ')' ...
            ' (orbit-anomaly# ' num2str(vars(2)) ')' ...
            ' (instruments ' instr_list_str ')' ...
            ' (lifetime ' num2str(params.lifetime) ')' ...
            ' (launch-date ' num2str(vars(3)) ')' ...
            '))'];
        r.eval(call);
        if arch(i)>6 % more than one instrument
            call = ['(assert (SYNERGIES::cross-registered-instruments '...
        ' (instruments ' instr_list_str ') '...
        ' (degree-of-cross-registration spacecraft) '...
        ' (platform ' params.satellite_names '-' num2str(i) ' ) '...
        '))' ];
            r.eval(call);
        end
    end
end

%% Call evaluator
results = RBES_Evaluate_Manifest(r,params);

score = results.score;
panel_scores = results.panel_scores;
data_continuity_score = results.data_continuity_score;

end