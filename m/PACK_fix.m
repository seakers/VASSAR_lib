function new = PACK_fix(seq)
new = seq;

%% relabel subset indices in increasing order starting from 1
pivs = java.util.HashMap;
for i = 1:length(seq)
    piv = seq(i);
    if pivs.containsKey(piv)
        new(i) = pivs.get(piv);
    else
        n = pivs.size;
        pivs.put(piv,n + 1);
        new(i) = n+1;
    end
end

%% remove empty satellites
for i = 2:length(new)
    if(new(i) > max(new(1:i-1)) + 1)
        new(i) = max(new(1:i-1)) + 1;
    end
end
end