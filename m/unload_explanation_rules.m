function [r,params] = unload_explanation_rules(r,params)
list_rules = r.listDefrules();
while list_rules.hasNext()
    rule = list_rules.next().getName();
    if rule.startsWith('REASONING')
        r.removeDefrule(rule);
    end
end
end