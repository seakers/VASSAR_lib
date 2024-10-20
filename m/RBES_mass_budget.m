function [mass,bus] = RBES_mass_budget
% global params
r = global_jess_engine();
%% Run mass budget RBES
r.eval('(focus MASS-BUDGET)');
r.run;
[~,values] = my_jess_query('MANIFEST::Mission','satellite-mass#',false);
mass = values{1};
mass = str2double(char(mass));
[~,values] = my_jess_query('MANIFEST::Mission','standard-bus',false);
bus = char(values{1});
end