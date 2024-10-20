function new = PACK_fix2(varargin)
if length(varargin{1}) == 1
%     JESS = true;
    seq = cell2mat(varargin);
else
%     JESS = false;
    seq  = varargin{1};
end
new = seq;

%% relabel subset indices in increasing order starting from 1
pivs = java.util.HashMap;
removed = [];
for i = 1:length(seq)
    piv = seq(i);
    if pivs.containsKey(piv)
        new(i) = pivs.get(piv);
    else
        n = pivs.size;
        pivs.put(piv,n + 1);
        if piv - n - 1 > length(removed)
            removed = [removed piv];
        end
        new(i) = n+1;
    end
end

%% remove empty satellites
for i = 2:length(new)
    if(new(i) > max(new(1:i-1)) + 1)
        new(i) = max(new(1:i-1)) + 1;
    end
end

%% add info on deleted subsets
new = [length(removed) removed new];
new = int8(new);

end