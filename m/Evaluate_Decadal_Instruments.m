%% Evaluate_Decadal_Instruments.m
n = length(names);
results.scores = zeros(n,1);
results.panel_scores = zeros(n,6);
for i = 1:n
    [r,results.scores(i),results.panel_scores(i,:),results.objective_scores{i},results.subobjective_scores{i}] = RBES_Evaluate_Instrument_fromExcel(r,...
        'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Instrument Capability Definition.xlsx',...
        names{i},params);
end