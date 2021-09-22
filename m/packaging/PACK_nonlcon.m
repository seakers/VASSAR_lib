function [c,ceq] = PACK_nonlcon(x)
c = 0;
ceq = [];
if x(1) ~= 1 
    c = 100;
    return;
end
for i = 2:length(x)
    if (x(i) > max(x(1:i-1)) + 1)
        c = 100;
        return;
    end
end


