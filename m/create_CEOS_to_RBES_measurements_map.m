function CEOS_to_RBES_measurements_map = create_CEOS_to_RBES_measurements_map(params)
filename = [params.precursor_missions_xls_path 'Measurements CEOS.xlsx'];
[~,txt,~] = xlsread(filename);
CEOS_to_RBES_measurements_map = java.util.HashMap;
CEOS_to_RBES_measurements(:,1) = txt(:,1);
CEOS_to_RBES_measurements(:,2) = txt(:,3);

for i = 1:147
    CEOS_to_RBES_measurements_map.put(CEOS_to_RBES_measurements{i,1},CEOS_to_RBES_measurements{i,2});
end
% save CEOS_to_RBES_measurements CEOS_to_RBES_measurements_map
end
