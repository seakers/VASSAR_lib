function new_arch = mutate_swap_one_instrument(varargin)
arch = cell2mat(varargin);
pos = randi(length(arch));% instrument position to change
old = arch(pos);
new = old;
while new==old
    new = randi(max(arch)+1);% can go to any previous sat or a new one
end
arch(pos) = new;
new_arch = PACK_fix(arch);

end