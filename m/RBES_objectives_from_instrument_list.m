function obj_list = RBES_objectives_from_instrument_list(instr_list)
%% RBES_objectives_from_instrument_list.m
% Usage:
% obj_list = RBES_objectives_from_instrument_list(instr_list)
% instr_list is a cell array of strings (instrument names)
% obj_list is a java.util.ArrayList
%
% This function returns an ArrayList of the objectives potentially
% (not necessarily) satisfied by the instruments in the list
%
global params
obj_list = java.util.ArrayList;
for i = 1:length(instr_list)
    objs = params.instruments_to_objectives.get(instr_list{i});
    obj_list.addAll(objs);
end
end