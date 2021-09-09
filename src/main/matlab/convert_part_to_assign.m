%% Convert Partitioning Architecture to Assigning Architecture
clear
close all
clc
instruments_list = ["ACE_ORCA", "ACE_POL", "ACE_LID", "CLAR_ERB", "ACE_CPR", "DESD_SAR", "DESD_LID", "GACM_VIS", "GACM_SWIR", "HYSP_TIR", "POSTEPS_IRS", "CNES_KaRIN"];
orbits_list = ["LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-DD"];

%% Conversion
arch_part = "0,1,1,2,2,2,2,2,2,3,4,4|0,1,2,2,2,-1,-1,-1,-1,-1,-1,-1"
arch_assignment = part_to_assign(arch_part, instruments_list, orbits_list)

%% Function
function arch_assign = part_to_assign(arch_part, instr_list, orb_list)
    n_instr = size(instr_list,2);
    n_orb = size(orb_list,2);
    
    arch_str_array = strsplit(arch_part,"|");
    
    % split the partitioning architecture to get the instrument partitions
    % and orbit assignments
    partitions = cell2mat(arch_str_array(1));
    instr_parts = strsplit(partitions,",");
    
    assignments = cell2mat(arch_str_array(2));
    orb_assigns = strsplit(assignments,",");
    
    partition_array = str2double(instr_parts);
    assignment_array = str2double(orb_assigns);
    
    % Convert to assignment architecture
    arch_assign = "";
    for i = 1:n_orb
        arch_assign_orb = zeros(1,n_instr);
        if ismember(i-1, assignment_array)
            partition_indices = find(assignment_array == i-1);
            for j = 1:length(partition_indices)
                instr_part_indices = partition_array == (partition_indices(j) - 1);
                arch_assign_orb(instr_part_indices) = 1;
            end 
        end
        arch_assign_orb_string = num2str(arch_assign_orb);
        arch_assign_orb_string = arch_assign_orb_string(arch_assign_orb_string ~= ' ');
        arch_assign = strcat(arch_assign, arch_assign_orb_string);
    end
end
            