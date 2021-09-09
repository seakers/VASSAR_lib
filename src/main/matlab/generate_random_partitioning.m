%% Generate random partitioning architectures
% Random partitioning architectures are generated as bitstrings for VASSAR testing
% Assumes Climate Centric Study (12 instruments, 5 orbits)
clear
close all
clc
instruments_list = ["ACE_ORCA", "ACE_POL", "ACE_LID", "CLAR_ERB", "ACE_CPR", "DESD_SAR", "DESD_LID", "GACM_VIS", "GACM_SWIR", "HYSP_TIR", "POSTEPS_IRS", "CNES_KaRIN"];
orbits_list = ["LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-DD"];

%% Generate partitioning architectures
n_arch = 10; % number of architectures to generate
arch_map = containers.Map;
arch_count = 0;

while arch_count < n_arch
    % Randomly generate instrument partitions
    arch_partition = zeros(size(instruments_list,2),1); 
    current_partition_index = randi([2,size(instruments_list,2)]);
    partition = 1;
    while current_partition_index < size(instruments_list,2)
        next_partition_index = randi([current_partition_index+1, size(instruments_list,2)]);
        arch_partition(current_partition_index:next_partition_index,1) = partition;
        current_partition_index = next_partition_index;
        partition = partition + 1;
    end
    
    % Randomly generate orbit assignments
    arch_assignment = ones(size(instruments_list,2),1).*-1;
    for i = 0:partition-1
        arch_assignment(i+1,1) = randi(size(orbits_list,2)) - 1;
    end
    
    % Convert to integer string 
    arch_string = num2str(arch_partition(1,1));
    for j = 2:size(instruments_list,2)
        arch_string = strcat(arch_string,",",num2str(arch_partition(j,1)));
    end
    arch_string = strcat(arch_string,"|",num2str(arch_assignment(1,1)));
    for k = 2:size(instruments_list,2)
        arch_string = strcat(arch_string,",",num2str(arch_assignment(k,1)));
    end
    
    % Add to map if unique
    if map_contains_arch(arch_map, arch_string)
        continue
    else
        field_name = strcat('arch',num2str(arch_count + 1));
        arch_map(field_name) = arch_string;
        arch_count = arch_count + 1;
    end
end

%% Read Map
arch_bools = values(arch_map);
for i = 1:n_arch
    disp(arch_bools{i})
end

%% Functions
function contains = map_contains_arch(map, arch) 
    contains = false;
    for j = keys(map)
        key = j{1};
        if strcmp(map(key),arch)
            contains = true;
            break
        end
    end
end  
