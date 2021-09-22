function overr = compute_cost_overrun(trl_list)
% fprintf('the instruments are %s\n',instruments);
min_TRL = 10;
for i = 0:trl_list.size-1
    if trl_list.get(i) < min_TRL
        min_TRL = trl_list.get(i);
    end
end
RSS = 8.29*exp(-0.56*min_TRL);
overr = 0.24*RSS+0.017;
end