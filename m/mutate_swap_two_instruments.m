function new_arch = mutate_swap_two_instruments(varargin)
arch = cell2mat(varargin);
same = true;
while(same)
    ind = randi(length(arch),[1 2]);% indices of instruments to swap
    same = isequal(ind./max(ind),ones(1,2));
end

tmp = arch(ind(2));%backup second instrument
arch(ind(2)) = arch(ind(1));
arch(ind(1)) = tmp;

new_arch = PACK_fix(arch);
end
