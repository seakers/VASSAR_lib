%% RBES_Evaluate_Instrument_fromExcel.m
function [r,score,panel_scores,objective_scores,subobjective_scores] = RBES_Evaluate_Instrument_fromExcel(r,filename,sheet,params)
% Ex of usage: [r,score,panel_scores] = Evaluate_Iridium_Instrument(('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Iridium Instrument Capability Definition.xlsx','BIOMASS');

% Documents\\PhD\\research\\projects\\Rule-based System Architecting\\EOLanguage\\facts_IRID_BIOMASS.clp


%% Import data to create fact file
[~,txt]= xlsread(filename,sheet);
num_measurements = size(txt,1);
fid = fopen('fact_file.clp','w');
for i = 1:num_measurements
    fprintf(fid,'(assert (REQUIREMENTS::Measurement');
    line = txt(i,:);
    for j = 2:length(line)
        att_value_pair = line{j};
        fprintf(fid,[' (' att_value_pair ') ']);
    end
    fprintf(fid,[' (taken-by ' sheet ') ']);
    fprintf(fid,'))\n');
    
end
fclose(fid);

r.reset;
r.eval('(batch fact_file.clp)')
r.eval('(focus REQUIREMENTS)');
r.run;



%% Compute objective satisfaction and overall benefit
[score,panel_scores,objective_scores,subobjective_scores] = compute_scientific_benefit(r,params);

%% Print results
r.eval('(focus REASONING)');
r.run;

% fprintf('Weather panel score: %f\n',weather_score);
% fprintf('Climate panel score: %f\n',climate_score);
% fprintf('Land panel score: %f\n',land_score);
% fprintf('Water panel score: %f\n',water_score);
% fprintf('Health panel score: %f\n',health_score);
% fprintf('Solid Earth panel score: %f\n',solidearth_score);
% fprintf('Total (average) score: %f\n',score);
return
