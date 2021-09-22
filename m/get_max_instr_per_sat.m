function n = get_max_instr_per_sat(varargin)
list = cell2mat(varargin);
sats = PACK_arch2sats(list);
n = max(cellfun(@length,sats));
end