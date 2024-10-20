%% RBES_compute_hashmaps_measurements_to_panels.m
function [meas2panels,panels2meas] = RBES_compute_hashmaps_measurements_to_panels(params)
meas2panels = java.util.HashMap;
panels2meas = java.util.HashMap;

[num,~,~]= xlsread(params.requirement_rules_xls,'Aggregation rules');
[num2,txt]= xlsread(params.requirement_rules_xls,'Requirement rules');

2