function SCHED_EOS_down_selection_constraints()
assert_down_selection_rule('min-data-continuity',0.95);
assert_down_selection_rule('min-discounted-value',0.95);
assert_down_selection_rule('min-utility',0.6);
assert_down_selection_rule('min-pareto',5);
%assert_down_selection_rule('max-risk',3);% max diff in TRL = 3
%assert_down_selection_rule('min-fairness',0.01);% something to each panel
end