function r = load_rules(r,panels)
climate = panels(1);
weather = panels(2);
if climate
    r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate1.clp")');
    r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate2.clp")');
    r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate3.clp")');
    r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate4.clp")');
    r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate5.clp")');
    r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_climate5.clp")');
end
if weather
    r.eval('(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\src\\rules_objective_weather1.clp")');

end

return 