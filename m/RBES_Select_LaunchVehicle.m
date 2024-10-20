%% RBES_Select_LaunchVehicle.m
function [lv,pack_factor] = RBES_Select_LaunchVehicle
% global params
r = global_jess_engine();
%% Run lv RBES
r.eval('(focus LV-SELECTION)');
r.run(1000);
[~,lv] = get_all_data('MANIFEST::Mission',{'launch-vehicle'},{'single-char'},0);

[~,values] = my_jess_query('MANIFEST::Mission','lv-pack-efficiency#',false);
pack_factor = values{1};
pack_factor = str2double(char(pack_factor));
end