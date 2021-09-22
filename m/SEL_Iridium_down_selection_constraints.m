function SEL_Iridium_down_selection_constraints()
assert_down_selection_rule('max-cost',50);
assert_down_selection_rule('min-science',0.15);
assert_down_selection_rule('min-utility',0.55);
assert_down_selection_rule('min-pareto',3);
assert_down_selection_rule('max-risk',0.3 0);
assert_down_selection_rule('min-fairness',0.01);% something to each panel
assert_down_selection_rule('max-fit',2);

end