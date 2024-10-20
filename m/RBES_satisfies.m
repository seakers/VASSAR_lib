function bool = RBES_satisfies(meas_id,subobj)
global params
r = global_jess_engine();
bool = true;
sb = subobj;
tmp = params.subobjectives_to_measurements.get(strcat('?*subobj-',sb,'*'));
str = jess_value(r.eval(['(ppdefrule REQUIREMENTS::subobjective-' char(sb) '-nominal)']));

tmp2 = regexp(str,'\(Parameter "(?<param>[^"]+)"\)','tokens');
meas = tmp2{1};
meas = ['"' meas{1} '"'];
fprintf('Could satisfy %s because it measures %s but it misses it because: \n',char(sb), meas);
tmp2 = regexp(str,'\(SameOrBetter (?<att>\S+)\s(?<var>\S+)\s(?<thr>\S+)\)','names');
% fprintf('Required: ');
attributes = java.util.ArrayList;
missing = java.util.ArrayList;

for j = 1:length(tmp2)
    thr = tmp2(j).thr;
%     fprintf('%s >= %s   ',tmp2(j).att,thr);
    attributes.add(tmp2(j).att);
    [~,values] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ') (taken-by "' meas_id '")'],tmp2(j).att);
    compar = jess_value(r.eval(['(SameOrBetter ' tmp2(j).att ' ' char(values{1}) ' ' tmp2(j).thr ')']));
    if compar < 0
        bool = false;
        fprintf('Attribute %s is incorrect: required = at least %s, achieved = %s\n',tmp2(j).att,tmp2(j).thr, char(values{1}));
    end
end

clear facts values;
tmp3 = regexp(str,'\(defrule (?<lhs>.+) (not (REASONING::fully-satisfied (?<rest>.+)\)','names');
tmp2 = regexp(tmp3.lhs,'\((?<att>\S+)\s(?<thr>\S+)\)','names');
for j = 1:length(tmp2)
    thr = tmp2(j).thr;
    
    if ~strncmp(thr,'?',1) && ~strncmp(thr,'nil',3)
%         fprintf('*************\n');
%         fprintf('%s = %s \t',tmp2(j).att,thr);
        attributes.add(tmp2(j).att);
        [~,values] = my_jess_query(['REQUIREMENTS::Measurement (Parameter ' meas ') (taken-by "' meas_id '")'],tmp2(j).att);
        if ~strcmp(char(values{1}),tmp2(j).thr)
            bool = false;
            fprintf('Attribute %s is incorrect: required = exactly %s, achieved = %s\n',tmp2(j).att,tmp2(j).thr,char(values{1}));
        end
    end
    
%     fprintf('*************\n');
end


    
end
