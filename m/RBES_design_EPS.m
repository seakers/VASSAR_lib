function RBES_design_EPS
% global params
r = global_jess_engine();
%% Run power subsystem design RBES
r.eval('(focus EPS-DESIGN)');
r.run;