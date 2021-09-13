function arch = PACK_str_to_arch(str)
instr_list = RBES_get_parameter('packaging_instrument_list');
% instrument_indexes = RBES_get_parameter('packaging_instrument_indexes');
sats = regexp(str,'([^&]+)','tokens');% tmp = cell array, tmp{1} = 'MODIS CERES CERES-B';
nsat = length(sats);
arch = zeros(1,length(instr_list));
for i=1:nsat
    tmp = regexp(sats{i},'\s','split');
    instr_cells = tmp{1};%instr_cells{1} = cell (1,3) =  'MODIS'    'CERES'    'CERES-B'
    for j = 1:length(instr_cells)
        instr = instr_cells{j};
        index = strcmp(instr_list,instr);
        arch(index) = i;
    end
end
arch = PACK_fix(arch);
end