%% Convert VASSAAR_lib Assign architecture to EOSS Assign architecture
clear
close all
clc
instruments_list = ["ACE_ORCA", "ACE_POL", "ACE_LID", "CLAR_ERB", "ACE_CPR", "DESD_SAR", "DESD_LID", "GACM_VIS", "GACM_SWIR", "HYSP_TIR", "POSTEPS_IRS", "CNES_KaRIN"];
orbits_list = ["LEO-600-polar-NA", "SSO-600-SSO-AM", "SSO-600-SSO-DD", "SSO-800-SSO-PM", "SSO-800-SSO-DD"];

%% Convert architecture
arch_vassar = '000000000011000000000000000111110000111000001100000000000000';
arch_eoss = convert_vassar_to_eoss_assign(arch_vassar, instruments_list, orbits_list)

%% Function
function eoss_arch = convert_vassar_to_eoss_assign(vassar_arch, instr_list, orb_list)
    n_orbs = size(orb_list,2);
    n_instr = size(instr_list,2);
    
   % Convert bitstring to n_orbs x n_instr bit matrix (used in VASSAR_lib)
   vassar_bitmatrix = zeros(n_orbs, n_instr);
   for i = 1:n_orbs
       for j = 1:n_instr
           vassar_bitmatrix(i,j) = str2double(vassar_arch((i-1)*n_instr+j));
       end
   end
      
   % Convert n_orbs x n_instr bit matrix to n_instr x n_orbs (used in EOSS)
   vassar_bitmatrix_eoss = vassar_bitmatrix';
   
   % Convert to EOSS bitstring
   eoss_arch = '';
   for i = 1:n_instr
       for j = 1:n_orbs
           eoss_arch = strcat(eoss_arch, num2str(vassar_bitmatrix_eoss(i,j)));
       end
   end
end