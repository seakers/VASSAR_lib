function results = RBES_get_measuremements(parameter,slot_list)
 %(Measurement (All-weather ?aw) (Horizontal-Spatial-Resolution ?hsr) (Instrument ?instr) (launch-date ?ld) (lifetime ?lt) 
 % (Parameter ?param) (sensitivity-in-low-troposphere-PBL ?tro) (sensitivity-in-upper-stratosphere ?str) (Spectral-sampling ?ss) 
 % (taken-by ?tk) (Temporal-resolution ?tr) (Vertical-Spatial-Resolution ?vsr)))
r = global_jess_engine();

%% Definition
call = ['(defquery REQUIREMENTS::search-all-measurements-by-parameter-custom'  ' "Finds all measurements of this parameter in the campaign" ' ...
            '(declare (variables ?param)) ' ...
            '(REQUIREMENTS::Measurement (Parameter ?param) (taken-by ?tk) (Instrument ?instr)'];
var_names = cell(length(slot_list),1);
for i=1:length(slot_list)
    var_names{i} = ['x' num2str(i)];
    call = [call ' (' slot_list{i} ' ?' var_names{i} ')'];
end

%             ' (Temporal-resolution ?tr) (All-weather ?aw) (Horizontal-Spatial-Resolution ?hsr) (Spectral-sampling ?ss)' ...
%             '  (Vertical-Spatial-Resolution ?vsr) (sensitivity-in-low-troposphere-PBL ?tro) (sensitivity-in-upper-stratosphere ?str))' ...
call = [call '))'];
r.eval(call);

%% Execution
r.eval(['(bind ?result (run-query* REQUIREMENTS::search-all-measurements-by-parameter-custom "' parameter '"))']);
for i = 1:length(slot_list)
        r.eval(['(bind ?' slot_list{i} '-values (new java.util.ArrayList))']);
end

% r.eval('(bind ?lt (new java.util.ArrayList))');
r.eval('(bind ?names (new java.util.ArrayList))');
r.eval(['(while (?result next) (call ?' slot_list{i} '-values add (?result getString ' var_names{i} ' )) (call ?names add (?result getString tk)))']);
t = r.eval('(eq ?names (create$ nil))');
if ~t.equals('TRUE')
    for i = 1:length(slot_list)
        results.slot_values{i} = r.eval(['?' slot_list{i} '-values']).javaObjectValue(r.getGlobalContext());% VectorValue ld.get(0), ld.size
    end
    results.names = r.eval('?names').javaObjectValue(r.getGlobalContext());% VectorValue
end

%% Elimination

end
    