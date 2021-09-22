%% RBES_Select_StandardBus.m
function RBES_Select_StandardBus
% global params
r = global_jess_engine();
%% Run bus RBES
r.eval('(focus BUS-SELECTION)');
r.run;



end