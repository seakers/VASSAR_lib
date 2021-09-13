function RBES_delete_all_requirement_rules_except(subobj)
r = global_jess_engine();
list_rules = r.listDefrules();
while list_rules.hasNext()
    rule = list_rules.next().getName();
    if rule.startsWith('REQUIREMENTS::subobjective-') || rule.startsWith('SYNERGIES::subobjective-')
        if ~rule.contains(java.lang.String(subobj))
            r.removeDefrule(rule);
        end
    end
end
end