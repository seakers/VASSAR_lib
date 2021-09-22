function r = RBES_Init_DecadalRules()
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
return