function mass_budgets = RBES_get_mass_budgets(PLOT,TALK)
    [~, values] = my_jess_query( 'MANIFEST::Mission', 'Name', false);
    mass_budgets = cell(length(values),1);
    for i = 1:length(values)
        sat = char(values{i});
        result = jess(['run-query* MASS-BUDGET::get-mass-budget "' sat '"']);
        while result.next
            payload = result.getDouble('payload');
            eps = result.getDouble('eps-mass');
            adcs = result.getDouble('adcs-mass');
            thermal = result.getDouble('thermal-mass');
            avion = result.getDouble('av-mass');
            prop = result.getDouble('prop-mass');
            struct = result.getDouble('struct-mass');
            prop1 = result.getDouble('mp1');
            prop2 = result.getDouble('mp2');
            dry = result.getDouble('dry');
            wet = result.getDouble('wet');
            adap = result.getDouble('adap');
            launch = result.getDouble('launch');
        end
        mb = [payload eps adcs thermal avion prop struct dry prop1 prop2 wet adap launch];
        if TALK
            fprintf('Sat %s: payload = %.1f eps = %.1f adcs = %.1f therm = %.1f avion = %.1f\n',sat, payload,eps,adcs,thermal,avion);
            fprintf('Sat %s: prop = %.1f struct = %.1f prop1 = %.1f prop2 = %.1f\n',sat, prop,struct,prop1,prop2);
            fprintf('Sat %s: dry = %.1f wet = %.1f adap = %.1f launch = %.1f\n',sat, dry,wet,adap,launch);
        end
        if PLOT
%                 pie(mb(1:end-4));
%                 legend({'Payload','EPS','ADCS','Thermal','Avionics','Propulsion','Structure'});
            [sorted_vals,ind] = sort(mb(1:7),'descend');
            labels = {'Payload','EPS','ADCS','Thermal','Avionics','Propulsion','Structure'};
            sorted_labels = labels(ind);
            figure;
            bar(sorted_vals);
            set(gca,'XTickLabel',sorted_labels);
            title(['Mass budget for satellite ' sat]);
        end
        mass_budgets{i} = mb;
    end
end