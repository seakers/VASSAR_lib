function [pos,bool] = PACK_find_arch(arch,archs)
bool = false;
for i = 1:size(archs,1)
    if isequal(arch,archs(i,:))
        bool = true;
        pos = i;
        return;
    end
end
if ~bool, pos = -1;end

end