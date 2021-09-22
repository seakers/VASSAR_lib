function masses = RBES_design_spacecraft()
    TOL = 10;
    
    jess focus PRELIM-MASS-BUDGET;
    jess run;
    
    [~,values] = get_all_data('MANIFEST::Mission',{'satellite-dry-mass'},{'single-num'},0);
    old_masses = cellfun(@cell2mat,values);
    diffs = 1e5.*ones(size(old_masses));
    tolerance = TOL*length(old_masses);
    
    while(sum(diffs) > tolerance)
        jess focus CLEAN1;
        jess run;
        
        jess focus MASS-BUDGET;
        jess run;

        jess focus CLEAN2;
        jess run;

        jess focus UPDATE-MASS-BUDGET;
        jess run;
        
        [~,values] = get_all_data('MANIFEST::Mission',{'satellite-dry-mass'},{'single-num'},0);
        masses = cellfun(@cell2mat,values);
        
        diffs = abs(masses - old_masses);
        old_masses = masses;

    end
end