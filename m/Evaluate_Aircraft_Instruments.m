function scores = Evaluate_Aircraft_Instruments(fact_file)
[~,~,~,~,names] = textread(fact_file,'%s%s%s%s%s');% comes from dir facts*.clp > fact_file.txt
n = length(names);
[r,keys_to_attribs] = init_KBEOSS2();
scores = zeros(n,5);
for i = 1:n
    fprintf('Instrument %d: %s\n',i,names{i});
    r = load_globals(r);
    r = load_templates(r,keys_to_attribs);
    r = load_functions(r);
    r = load_rules(r);
    command = ['(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\' names{i} '")'];
    r.eval(command);
    r.setResetGlobals(false);    
    r.reset;
    r.run;
    [obj_C1,obj_C2,obj_C3,obj_C4,obj_C5] = get_climate_objectives_values(r);
    scores(i,:) = [obj_C1,obj_C2,obj_C3,obj_C4,obj_C5];
    r.clear;
    pause(1);
end
return