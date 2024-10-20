function str = get_str_from_arch(varargin)
type = varargin{1};
arch = cell2mat(varargin(2:end));
if strcmp(type,'SELECTION')
    str = SEL_arch_to_str(arch);
elseif strcmp(type,'PACKAGING')
    str = PACK_arch_to_str(arch);
elseif strcmp(type,'SCHEDULING')
    str = SCHED_arch_to_str(arch);
end
end