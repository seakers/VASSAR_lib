%% script_init_KBEOSS.m

%% Preliminaries
% Add path
javaaddpath('C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\dist\EOLanguage.jar')
javaaddpath('C:\Documents and Settings\Dani\My Documents\software\Jess71p2\lib\jess.jar');
javaaddpath('C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\build\classes\');

%% Import measurement attributes (global variables)
% Read xls Measurement attribute definitions
[num,txt]= xlsread('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\AttributeSet','Measurement');
attribs_to_keys = CreateAttributeListHashtable(num,txt);
keys_to_attribs = CreateAttributeKeysHashMap(num,txt);
attribs_to_types = CreateAttributeTypesHashMap(num,txt);
attribSet = CreateAttributeSetHashMap(num,txt);
GlobalVariables.defineMeasurement(attribs_to_keys,keys_to_attribs,attribs_to_types,attribSet);

%% Init Jess
import jess.*
r = jess.Rete();
r.eval('(watch all)');

%% Import global variables for objective definition
r = load_globals(r);

%% Create Measuremenet template
r = load_templates(r,keys_to_attribs);

%% User functions
r = load_functions(r);

%% Import rules for subobjectives (from excel?)
r = load_rules(r,[1 0]);% climate,weather,...

%% Facts: Import instrument characteristics
r = load_aircraft_instruments(r);
