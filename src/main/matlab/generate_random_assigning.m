%% Generate random assigning architectures
% Random assigning architectures are generated as bitstrings for VASSAR testing
% Assumes Climate Centric Study (12 instruments, 5 orbits)
clear
close all
clc
instruments_list = ["ACE_ORCA", "ACE_POL", "ACE_LID", "CLAR_ERB", "ACE_CPR", "DESD_SAR", "DESD_LID", "GACM_VIS", "GACM_SWIR", "HYSP_TIR", "POSTEPS_IRS", "CNES_KaRIN"];
orbits_list = ["LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-DD"];

%% Generate assigning architectures
n_arch = 10; % number of architectures to generate
arch_map = containers.Map;
arch_count = 0;

while arch_count < n_arch
    arch_bin = randi([0 1],1,60); % generates a binary array sequence 60 bits long
    
    % Convert binary array to bitstring
    arch_bool = "";
    for j = 1:size(arch_bin,2)
        arch_bool = strcat(arch_bool,num2str(arch_bin(1,j)));
    end
    if map_contains_arch(arch_map, arch_bool)
        continue
    else
        field_name = strcat('arch',num2str(arch_count + 1));
        arch_map(field_name) = arch_bool;
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