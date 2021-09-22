function [missing] = RBES_why_not2(subobj)
% global params
r = global_jess_engine();

% str = ['jess ppdefrule REQUIREMENTS::subobjective-' subobj '-nominal'];
% eval(str);
% str = ['jess ppdefrule CAPABILITIES::' instr '-measurements'];
% eval(str);

sb = subobj;
str = jess_value(r.eval(['(ppdefrule REQUIREMENTS::subobjective-' char(sb) '-nominal)']));

tmp2 = regexp(str,'\(Parameter "(?<param>[^"]+)"\)','tokens');
meas = tmp2{1};
meas = ['"' meas{1} '"'];
fprintf('Could satisfy %s because it measures %s but it completely misses it\n',char(sb), meas);
str = jess_value(r.eval(['(ppdefrule REQUIREMENTS::subobjective-' char(sb) '-nominal)']));
tmp2 = regexp(str,'\(SameOrBetter (?<att>\S+)\s(?<var>\S+)\s(?<thr>\S+)\)','names');
fprintf('Required: ');
attributes = java.util.ArrayList;
missing = java.util.ArrayList;

for j = 1:length(tmp2)
    thr = tmp2(j).thr;
    fprintf('%s >= %s   ',tmp2(j).att,thr);
    attributes.add(tmp2(j).att);
%     [facts,values] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ')'],tmp2(j).att);
end

clear facts values;
tmp3 = regexp(str,'\(defrule (?<lhs>.+) (not (REASONING::fully-satisfied (?<rest>.+)\)','names');
tmp2 = regexp(tmp3.lhs,'\((?<att>\S+)\s(?<thr>\S+)\)','names');
for j = 1:length(tmp2)
    thr = tmp2(j).thr;
    
    if ~strncmp(thr,'?',1)
%         fprintf('*************\n');
        fprintf('%s = %s \t',tmp2(j).att,thr);
        attributes.add(tmp2(j).att);
    end
%     [facts,values] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ')'],tmp2(j).att);
%     fprintf('*************\n');
end
fprintf('\n');
        

fprintf('Achieved:\n');
[facts,values] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ')'],'taken-by');
attribs = cell(attributes.toArray);
for i = 1:length(facts)
    takenby = values{i};
    attrs = RBES_get_values2(facts{i}.getFactId,attribs);
    fprintf('%s (%d) ==> ',char(takenby),jess_value(facts{i}.getSlotValue('synergy-level#')));
    for j = 1:length(attrs)
        fprintf('%s = %s \t',attribs{j},attrs{j});
    end
    fprintf('\n');
end
fprintf('\n');
% r.eval(['(bind ?result (run-query* REQUIREMENTS::search-all-measurements-by-parameter "' parameter '"))']);
% r.eval('(bind ?ld (new java.util.ArrayList))');
% r.eval('(bind ?lt (new java.util.ArrayList))');
% r.eval('(bind ?names (new java.util.ArrayList))');
% r.eval('(while (?result next) (call ?ld add (?result getString ld)) (call ?lt add (?result getString lt)) (call ?names add (?result getString tk)))');
% t = r.eval('(eq ?ld (create$ nil))');
% if ~t.equals('TRUE')
%     ld = r.eval('?ld').javaObjectValue(r.getGlobalContext());% VectorValue ld.get(0), ld.size
%     lt = r.eval('?lt').javaObjectValue(r.getGlobalContext());% VectorValue
%     names = r.eval('?names').javaObjectValue(r.getGlobalContext());% VectorValue
%     for j = 1:ld.size
%         ld_val = str2num(ld.get(j-1));
%         lt_val = str2num(lt.get(j-1));
%         name = names.get(j-1);
%     end
% end
    
end