function [r,params] = load_instrument2measurement_inheritance_rules(r,params)
[~,txt,~] = xlsread(params.template_definition_xls,'Attribute Inheritance');
instr2meas = txt(:,3:4);

%% Instrument to measurement
for i =2:size(instr2meas,1)
    att = instr2meas{i,1};
    inherit = instr2meas{i,2};
    if strcmp(inherit,'Instrument') % Inherit directly from Instrument
        call = ['(defrule CAPABILITIES::get-' att '-from-instrument ' ...
        ' (declare (salience -10)) ' ...
        ' ?meas <- (REQUIREMENTS::Measurement (taken-by ?instr) (' att ' nil)) ' ...
        ' (CAPABILITIES::Manifested-instrument (Name ?instr) (' att ' ?value&:(neq ?value nil))) ' ...
         ' => ' ...
        ' (modify ?meas (' att ' ?value)) ' ...
        ' )'];
        r.eval(call);
    end
end
end