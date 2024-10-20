function save_best_orbits()
global params
caso = params.CASE_STUDY;
best_orbits = params.best_orbits;
if strcmp(caso,'DECADAL')
    
    save('./mat/Decadal_best_orbits.mat','best_orbits');
elseif strcmp(caso,'EOS')
    save('./mat/EOS_best_orbits.mat','best_orbits');
else
end