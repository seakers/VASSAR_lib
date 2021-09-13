function bool = break_apart_req(varargin)
tmp = cellfun(@isstr,varargin);
instr = varargin(tmp);
arch = cell2mat(varargin(~tmp));

ind0 = arch(get_packaging_instrument_index(instr{1}));
bool = false;
for i = 2:length(instr)
    ind = arch(get_packaging_instrument_index(instr{i}));
    if ind == ind0
        bool = true;
        break;
    end
end

end