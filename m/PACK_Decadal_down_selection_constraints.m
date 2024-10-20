function PACK_Decadal_down_selection_constraints()
% assert_down_selection_rule('max-cost',6600);
% assert_down_selection_rule('min-science',0.50);
% assert_down_selection_rule('min-utility',0.6);
% assert_down_selection_rule('min-pareto',6);
% assert_down_selection_rule('max-risk',0.7);% max diff in TRL = 3
% assert_down_selection_rule('max-launch-risk',0.55);% max diff in TRL = 3

assert_down_selection_rule('max-cost',10000);
assert_down_selection_rule('min-science',0.30);
assert_down_selection_rule('min-utility',0.6);
assert_down_selection_rule('min-pareto',4);
assert_down_selection_rule('max-risk',0.5);% max diff in TRL = 3
assert_down_selection_rule('max-launch-risk',0.5);% max diff in TRL = 3
end