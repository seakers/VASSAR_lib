function load_launch_vehicle_selection_rules
%% load_launch_vehicle_selection_rules.m
global params
r = global_jess_engine();

%% Get data from xls
[~,~,raw] = xlsread(params.mission_analysis_database_xls,'Launch vehicles');
slot_names = raw(:,2);
lv_list = raw(strcmp(slot_names,'id'),3:end);
costs = cell2mat(raw(strcmp(slot_names,'cost'),3:end));

payload_GEOs = raw(strcmp(slot_names,'payload-GEO'),3:end);
payload_LEOpolars = raw(strcmp(slot_names,'payload-LEO-polar'),3:end);
payload_LEOequats = raw(strcmp(slot_names,'payload-LEO-equat'),3:end);
payload_SSOs = raw(strcmp(slot_names,'payload-SSO'),3:end);
payload_MEOs = raw(strcmp(slot_names,'payload-MEO'),3:end);
payload_HEOs = raw(strcmp(slot_names,'payload-HEO'),3:end);

diameters = cell2mat(raw(strcmp(slot_names,'diameter'),3:end));
heights = cell2mat(raw(strcmp(slot_names,'height'),3:end));

%% Assert all possible launch vehicles
r.eval(['(defrule LV-SELECTION::assert-all-possible-lvs' ...
'(declare (salience 20))' ...
'?orig <- (MANIFEST::Mission (launch-vehicle nil))' ...
'=> '...
'(foreach ?lv (create$ ' StringArraytoStringWithSpaces(lv_list) ' )' ...
    '(duplicate ?orig (launch-vehicle ?lv)' ...
        '))' ...
'(retract ?orig))']);

%% LV cost
call = ['(deffunction get-launch-cost (?lv) ' ...
    '(if (eq ?lv ' lv_list{1} ') then (return ' num2str(costs(1)) ' ) '];
n = length(lv_list);
for j = 2:n
    call = [call 'elif (eq ?lv ' lv_list{j} ' ) then (return ' num2str(costs(j)) ' )' ];
end
       
call = [call ' else (return 500)))'];
r.eval(call);

%% LV performance
call = '(deffunction get-perf-coeffs-lv (?lv ?typ ?inc) ';
for i = 1:length(lv_list)
    add_call = ['(if (eq ?lv ' lv_list{i} ') then '];   
    add_call = [add_call ' (if (and (eq ?typ LEO) (eq ?inc polar)) then (return ' txt_array_to_jess_list(payload_LEOpolars{i}) '))'];
    add_call = [add_call ' (if (and (eq ?typ SSO)             ) then (return ' txt_array_to_jess_list(payload_SSOs{i}) '))'];
    add_call = [add_call ' (if (and (eq ?typ LEO) (eq ?inc equat)) then (return ' txt_array_to_jess_list(payload_LEOequats{i}) '))'];
    add_call = [add_call ' (if  (eq ?typ GEO) then (return ' txt_array_to_jess_list(payload_GEOs{i}) ')) '];
    add_call = [add_call ' (if  (eq ?typ MEO) then (return ' txt_array_to_jess_list(payload_MEOs{i}) ')) '];   
    add_call = [add_call ' (if  (eq ?typ HEO) then (return ' txt_array_to_jess_list(payload_HEOs{i}) ')) '];   
    add_call = [add_call ') '];   
    call = [call add_call];    
end
call = [call ')'];
r.eval(call);

for i = 1:n
    call = ['(deffunction get-performance-' lv_list{i} ' (?type ?a ?i) '  ...
    '(bind ?coeffs (get-perf-coeffs-lv ' lv_list{i} ' ?type ?i))' ...
    '(bind ?h (- ?a 6378))' ... 
    '(bind ?perf (dot-product$ ?coeffs (create$ 1 ?h (** ?h 2))))' ...
    ' (return ?perf))'];
    r.eval(call);
end

call = '(deffunction get-performance (?lv ?type ?h ?i) ';
call = [call '(if (eq ?lv ' lv_list{1} ') then (get-performance-' lv_list{1} ' ?type ?h ?i)'];
for i = 2:n
    call = [call ' elif (eq ?lv ' lv_list{i} ') then (get-performance-' lv_list{i} ' ?type ?h ?i)'];  
end
call = [call ' else (return 0.0)))'];
r.eval(call);  
   
%% LV volume
call = ['(deffunction get-launch-fairing-dimensions (?lv) ' ...
    '(if (eq ?lv ' lv_list{1} ') then (return (create$ ' num2str(diameters(1)) ' ' num2str(heights(1)) ')) '];
n = length(lv_list);
for j = 2:n
    call = [call 'elif (eq ?lv ' lv_list{j} ' ) then (return (create$ ' num2str(diameters(j)) ' ' num2str(heights(j)) ')) '];
end
       
call = [call ' else (return (create$ 0 0))))'];
r.eval(call);

%% Rest of rules from clp
r.eval(['(bind ?launch_vehicle_selection_rules_clp "' params.launch_vehicle_selection_rules_clp '")']);
r.eval('(batch ?launch_vehicle_selection_rules_clp)');

end