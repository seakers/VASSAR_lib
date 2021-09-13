function new_arch = improve_remove_interference(varargin)
global params
arch = cell2mat(varargin);
current_interferences = PACK_get_current_interferences(arch);
new_arch = arch;
n = size(current_interferences,1);
if n > 0
    interf = current_interferences(randi(n),:);
    instr1 = strcmp(params.packaging_instrument_list,interf{1});
    instr2 = strcmp(params.packaging_instrument_list,interf{2});
    
    new_arch(instr2) = new_arch(instr1)+1;
    
    new_arch = PACK_fix(new_arch);
else
end
end