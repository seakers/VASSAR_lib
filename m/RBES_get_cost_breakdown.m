function costs = RBES_get_cost_breakdown(miss)
r = global_jess_engine();
costs = cell2mat(jess_value(r.eval(['(get-cost-breakdown ' miss ')'])));
fprintf('Cost breakdown mission %s: payload = %d, bus = %d, launch = %d, program = %d, IA&T = %d, ops = %d, total = %d\n',...
miss,round(costs(1)),round(costs(2)),round(costs(3)),round(costs(4)),round(costs(5)),round(costs(6)),round(costs(7)));
end