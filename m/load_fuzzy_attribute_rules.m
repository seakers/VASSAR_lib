function load_fuzzy_attribute_rules
%% load_fuzzy_attribute_rules.m
global params
r = global_jess_engine();

[~,~,raw]= xlsread(params.template_definition_xls,'Fuzzy Attributes');
for i = 2:size(raw,1)
    att = raw{i,1};
    param = raw{i,2};
    unit = raw{i,3};
    num_values = raw{i,4};
    fuzzy_values = cell(1,num_values);
    mins = zeros(1,num_values);
    means = zeros(1,num_values);
    maxs = zeros(1,num_values);
    
    call_values = '(create$ ';
    call_mins = '(create$ ';
    call_maxs = '(create$ ';
    for j = 1:num_values
        fuzzy_values{j} = raw{i,1+4*j};
        call_values = [call_values fuzzy_values{j} ' '];
        mins(j) = raw{i,2+4*j};
        call_mins = [call_mins num2str(mins(j)) ' '];
        means(j) = raw{i,3+4*j};
        maxs(j) = raw{i,4+4*j};
        call_maxs = [call_maxs num2str(maxs(j)) ' '];
    end
    call_values = [call_values ')'];
    call_mins = [call_mins ')'];
    call_maxs = [call_maxs ')'];

   if strcmp(param,'all')
       call = ['(defrule FUZZY::numerical-to-fuzzy-' att ...
           ' "Transforms a numerical value into a fuzzy qualitative value for all parameters" '...
           '?m <- (REQUIREMENTS::Measurement (' att '# ?num&~nil) (' att ' nil)) ' ...
           ' => ' ...
           '(bind ?value (numerical-to-fuzzy ?num ' call_values ' ' call_mins ' ' call_maxs ' )) ' ...
           ' (modify ?m (' att ' ?value))) ' ...
           ];
   else
       attminus2 = att(1:end-1);% remove the 2
       call = ['(defrule FUZZY::numerical-to-fuzzy-' att ...
           ' "Transforms a numerical value into a fuzzy qualitative value for a specific parameter" '...
           ' (declare (salience 10)) ' ...
           '?m <- (REQUIREMENTS::Measurement (Parameter "' param '") (' attminus2 '# ?num&~nil) (' att ' nil)) ' ...
           ' => ' ...
           '(bind ?value (numerical-to-fuzzy ?num ' call_values ' ' call_mins ' ' call_maxs ' )) ' ...
           ' (modify ?m (' att ' ?value))) ' ...
           ];
   end
   
   r.eval(call);
end


return
