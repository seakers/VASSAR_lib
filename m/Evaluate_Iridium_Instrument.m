%% Evaluate_Iridium_Instrument.m
function [r,score,panel_scores] = Evaluate_Iridium_Instrument(instr_name)
% Ex of usage: [r,score,panel_scores] = Evaluate_Iridium_Instrument('IRID_BIOMASS')
% Assumes a fact file exists with the name:
% C:\\Documents and Settings\\Dani\\My
% Documents\\PhD\\research\\projects\\Rule-based System Architecting\\EOLanguage\\facts_IRID_BIOMASS.clp

[r,keys_to_attribs] = init_KBEOSS2();

%% Import global variables for objective definition
r = load_globals(r);

%% Create Measuremenet template
r = load_templates(r,keys_to_attribs);

%% User functions
r = load_functions(r);

%% Import rules for subobjectives (from excel?)
% panels = [0 1];% climate weather
% r = load_rules(r,panels);
load_rules_from_excel(r,'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Weather');
load_rules_from_excel(r,'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Land');
load_rules_from_excel(r,'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Water');
load_rules_from_excel(r,'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','SolidEarth');
load_rules_from_excel(r,'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Health');
load_rules_from_excel(r,'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Climate');



%% Facts: Import test measurements
% command = '(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\facts_test_measurements2.clp")';
% r.eval(command);
% r = create_test_facts_from_excel(r,'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx','Health');
% r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\PhD\\research\\projects\\Rule-based System Architecting\\EOLanguage\\facts_IRID_BIOMASS.clp")');
% r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\PhD\\research\\projects\\Rule-based System Architecting\\EOLanguage\\facts_IRID_MUSE.clp")');
% r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\PhD\\research\\projects\\Rule-based System Architecting\\EOLanguage\\facts_IRID_LORENTZ_ERB.clp")');
% r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\PhD\\research\\projects\\Rule-based System Architecting\\EOLanguage\\facts_IRID_CTECS.clp")');
pre = '(batch  "C:\\Documents and Settings\\Dani\\My Documents\\PhD\\research\\projects\\Rule-based System Architecting\\EOLanguage\\facts_';
post = '.clp")';
cmd = [pre instr_name post];
r.eval(cmd);

%% Run jess
r.setResetGlobals(false);    
r.reset;
r.run;

%% Compute objective satisfaction and overall benefit
[obj_HE1,obj_HE2,obj_HE3,obj_HE4,obj_HE5,obj_HE6,health_score]           = get_health_objectives_values(r);
[obj_WE1,obj_WE2,obj_WE3,obj_WE4,obj_WE5,obj_WE6,obj_WE7,weather_score]   = get_weather_objectives_values(r);
[obj_WA1,obj_WA2,obj_WA3,obj_WA4,obj_WA5,obj_WA6,obj_WA7,water_score]   = get_water_objectives_values(r);
[obj_ECO1,obj_ECO2,obj_ECO3,obj_ECO4,obj_ECO5,land_score]              = get_land_objectives_values(r);
[obj_C1,obj_C2,obj_C3,obj_C4,obj_C5,climate_score]                        = get_climate_objectives_values(r);
[obj_SE1,obj_SE2,obj_SE3,obj_SE4,obj_SE5,solidearth_score]                   = get_solidearth_objectives_values(r);
panel_scores = [health_score weather_score water_score land_score climate_score solidearth_score]';
score = [0.111 0.214 0.156 0.206 0.206 0.107]*panel_scores;
%% Print results
fprintf('Weather panel score: %f\n',weather_score);
fprintf('Climate panel score: %f\n',climate_score);
fprintf('Land panel score: %f\n',land_score);
fprintf('Water panel score: %f\n',water_score);
fprintf('Health panel score: %f\n',health_score);
fprintf('Solid Earth panel score: %f\n',solidearth_score);
fprintf('Total (average) score: %f\n',score);
return
