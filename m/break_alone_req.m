function bool = break_alone_req(varargin)
% global params
tmp = cellfun(@isstr,varargin);
instr = varargin(tmp);
arch = cell2mat(varargin(~tmp));

index = get_packaging_instrument_index(instr{1});
ind0 = arch(index);
bool = false;
for i = 1:length(arch)
    if i ~= index
        ind = arch(i);
        if ind == ind0
            bool = true;
            break;
        end
    end
end

end