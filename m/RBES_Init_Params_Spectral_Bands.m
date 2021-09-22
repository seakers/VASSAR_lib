%% RBES_Init_Params_Spectral_Bands.m

% Paths for Java classes
params.javaaddpath = cell(1,3);
params.javaaddpath{1} = 'C:\Documents and Settings\Dani\My Documents\software\Jess71p2\lib\jess.jar';
params.javaaddpath{2} = 'C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\dist\EOLanguage.jar';
params.javaaddpath{3} = 'C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\build\classes\';

% Paths for xls files 
params.template_definition_xls = 'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\AttributeSet';
params.requirement_rules_xls = 'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Decadal Objective Rule Definition.xlsx';
params.capability_rules_xls = 'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Imagers Instrument Capability Definition.xlsx';
params.attribute_inheritance_rules_xls = 'C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\Attribute Inheritance Rules.xlsx';

% Paths for clp files
params.module_definition_clp = 'C:\\Documents and Settings\\Dani\\workspace\\RBES_EOSS\\src\\modules.clp';
params.attribute_inheritance_clp = 'C:\\Documents and Settings\\Dani\\workspace\\RBES_EOSS\\src\\attribute_inheritance_rules.clp';
params.synergy_rules_clp = 'C:\\Documents and Settings\\Dani\\workspace\\RBES_EOSS\\src\\synergy_rules.clp';
params.explanation_rules_clp = 'C:\\Documents and Settings\\Dani\\workspace\\RBES_EOSS\\src\\explanation_rules.clp';

% Pool of instruments to be considered
params.instrument_list = {'UV_IMAGER','VIS_IMAGER','NIR_IMAGER','SWIR_IMAGER','TIR_IMAGER'};

% Watch
params.WATCH = 0;