function [] = RBES_get_mass_budget(name)
[facts,~] = my_jess_query(['MANIFEST::Mission (Name ' name ' )'],'ADCS-mass#');
id = facts{1}.getFactId();
values = RBES_get_values(id,{'ADCS-mass#','comm-OBDH-mass#','EPS-mass#','structure-mass#','thermal-mass#','payload-mass#','satellite-mass#'});
% fprintf('ADCS = %f, comm = %f, EPS = %f, structure = %f, payload = %f, total = %f\n',values{1},values{2},values{3},values{4},values{5},values{6},values{7});
end