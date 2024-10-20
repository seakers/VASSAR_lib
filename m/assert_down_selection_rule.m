function assert_down_selection_rule(type,value)
r = global_jess_engine();
if (strcmp(type,'max-cost'))
    r.eval(['(assert (DOWN-SELECTION::MAX-COST (max-cost ' num2str(value) ' )))']);
elseif (strcmp(type,'min-science'))
    r.eval(['(assert (DOWN-SELECTION::MIN-SCIENCE (min-science ' num2str(value) ' )))']);
elseif (strcmp(type,'min-utility'))
    r.eval(['(assert (DOWN-SELECTION::MIN-UTILITY (min-utility ' num2str(value) ' )))']);
elseif (strcmp(type,'min-pareto'))
    r.eval(['(assert (DOWN-SELECTION::MIN-PARETO-RANK (min-pareto-rank ' num2str(value) ' )))']);
elseif (strcmp(type,'max-risk'))
    r.eval(['(assert (DOWN-SELECTION::MAX-PROG-RISK (max-programmatic-risk ' num2str(value) ' )))']);
elseif (strcmp(type,'max-launch-risk'))
    r.eval(['(assert (DOWN-SELECTION::MAX-LAUNCH-RISK (max-launch-risk ' num2str(value) ' )))']);
elseif (strcmp(type,'min-fairness'))
    r.eval(['(assert (DOWN-SELECTION::MIN-FAIRNESS (min-fairness ' num2str(value) ' )))']);
elseif (strcmp(type,'min-data-continuity'))
    r.eval(['(assert (DOWN-SELECTION::MIN-DATA-CONTINUITY (min-data-continuity ' num2str(value) ' )))']);
elseif (strcmp(type,'min-discounted-value'))
    r.eval(['(assert (DOWN-SELECTION::MIN-DISCOUNTED-VALUE (min-discounted-value ' num2str(value) ' )))']);
elseif (strcmp(type,'max-fit'))
    r.eval(['(assert (DOWN-SELECTION::MAX-FIT (max-fit ' num2str(value) ' )))']);
end


end
