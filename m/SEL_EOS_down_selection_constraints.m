function SEL_EOS_down_selection_constraints()
assert_down_selection_rule('max-cost',10000);
assert_down_selection_rule('min-science',0.67);
assert_down_selection_rule('min-utility',0.5);
assert_down_selection_rule('min-pareto',3);
assert_down_selection_rule('max-risk',0.4);
% assert_down_selection_rule('min-fairness',0.01);% something to each panel
end