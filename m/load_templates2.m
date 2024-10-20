function load_templates2()
global params
r = global_jess_engine();

%% Measurement
[num,txt]= xlsread(params.template_definition_xls,'Measurement');
types = txt(2:end,1);
txt = txt(:,2:end);

attribs_to_keys = CreateAttributeListHashtable(num,txt);
keys_to_attribs = CreateAttributeKeysHashMap(num,txt);
attribs_to_types = CreateAttributeTypesHashMap(num,txt);
attribSet = CreateAttributeSetHashMap(num,txt);
GlobalVariables.defineMeasurement(attribs_to_keys,keys_to_attribs,attribs_to_types,attribSet);
params.list_of_attributes = keys_to_attribs;
params.attribs_to_types = attribs_to_types;
call = '(deftemplate REQUIREMENTS::Measurement "A measurement"';
for i = 1:params.list_of_attributes.size
    attrib = params.list_of_attributes.get(java.lang.Integer(i));
    if strcmp(types{i},'slot')
        call = [call ' (slot ' attrib ')'];
    elseif strcmp(types{i},'multislot')
        call = [call ' (multislot ' attrib ')'];
    end
end
call = [call '(multislot spectral-bands)'];
call = [call '(slot taken-by) )'];
r.eval(call);


%% Instrument
[num,txt]= xlsread(params.template_definition_xls,'Instrument');
types = txt(2:end,1);
txt = txt(:,2:end);
attribs_to_keys = CreateAttributeListHashtable(num,txt);
params.list_of_instrument_attributes = CreateAttributeKeysHashMap(num,txt);
attribs_to_types = CreateAttributeTypesHashMap(num,txt);
attribSet = CreateAttributeSetHashMap(num,txt);

GlobalVariables.defineInstrument(attribs_to_keys,keys_to_attribs,attribs_to_types,attribSet);

call = '(deftemplate DATABASE::Instrument "An instrument, in the database of this case study"';
for i = 1:params.list_of_instrument_attributes.size
    attrib = params.list_of_instrument_attributes.get(java.lang.Integer(i));
%     attrib = regexprep(attrib, '/', '-');
%     attribs_to_keys.put(java.lang.Integer(i),attrib);
    if strcmp(types{i},'slot')
        call = [call ' (slot ' attrib ')'];
    elseif strcmp(types{i},'multislot')
        call = [call ' (multislot ' attrib ')'];
    end
end
% call = [call '(slot flies-in)'];
call = [call '(multislot spectral-bands)'];

call = [call '(multislot measurement-ids) )'];

r.eval(call);

call = '(deftemplate CAPABILITIES::Manifested-instrument "An instrument that has been manifested in a mission"';
for i = 1:params.list_of_instrument_attributes.size
    attrib = params.list_of_instrument_attributes.get(java.lang.Integer(i));
%     attrib = regexprep(attrib, '/', '-');
%     attribs_to_keys.put(java.lang.Integer(i),attrib);
    if strcmp(types{i},'slot')
        call = [call ' (slot ' attrib ')'];
    elseif strcmp(types{i},'multislot')
        call = [call ' (multislot ' attrib ')'];
    end
end
call = [call '(multislot spectral-bands)'];
call = [call '(slot flies-in)'];
call = [call '(multislot measurement-ids) )'];

r.eval(call);


%% Mission
[num,txt]= xlsread(params.template_definition_xls,'Mission');
types = txt(2:end,1);
txt = txt(:,2:end);
params.list_of_mission_attributes = CreateAttributeKeysHashMap(num,txt);

call = '(deftemplate MANIFEST::Mission "A mission"';
for i = 1:params.list_of_mission_attributes.size
    attrib = params.list_of_mission_attributes.get(java.lang.Integer(i));
%     attrib = regexprep(attrib, '/', '-');
%     attribs_to_keys.put(java.lang.Integer(i),attrib);
    if strcmp(types{i},'slot')
        call = [call ' (slot ' attrib ')'];
    elseif strcmp(types{i},'multislot')
        call = [call ' (multislot ' attrib ')'];
    end
end
% call = [call '(slot flies-in)'];
call = [call ' (multislot payload-dimensions#)'];
call = [call ' (multislot partnership-type)'];
call = [call ' (multislot instruments))'];
r.eval(call);

% call= ['(deftemplate MANIFEST::Mission "A mission" ' ...
%     ' (slot Name) ' ...
%     ' (slot mission-architecture)' ...
%     ' (slot num-of-planes#)  ' ...
%     ' (slot num-of-sats-per-plane#)  ' ...
%     ' (multislot instruments)  ' ...
%     ' (slot orbit-altitude#) ' ...
%     ' (slot orbit-type) ' ...
%     ' (slot orbit-inclination) ' ...
%    '  )'];
% r.eval(call);    
    
%% Orbit
[num,txt]= xlsread(params.template_definition_xls,'Orbit');
types = txt(2:end,1);
txt = txt(:,2:end);
params.list_of_orbit_attributes = CreateAttributeKeysHashMap(num,txt);

call = '(deftemplate DATABASE::Orbit "An orbit"';
for i = 1:params.list_of_orbit_attributes.size
    attrib = params.list_of_orbit_attributes.get(java.lang.Integer(i));
%     attrib = regexprep(attrib, '/', '-');
%     attribs_to_keys.put(java.lang.Integer(i),attrib);
    if strcmp(types{i},'slot')
        call = [call ' (slot ' attrib ')'];
    elseif strcmp(types{i},'multislot')
        call = [call ' (multislot ' attrib ')'];
    end
end
% call = [call '(slot flies-in)'];
% call = [call '(multislot measurement-ids) )'];
call = [call ')'];
r.eval(call);   

%% Revisit time database

call= ['(deftemplate DATABASE::Revisit-time-of "Revisit time of an architecture-orbit-instrument tuple" ' ...
    ' (slot mission-architecture) ' ...
    ' (slot num-of-planes#)  ' ...
    ' (slot num-of-sats-per-plane#)  ' ...
    ' (slot orbit-altitude#) ' ...
    ' (slot orbit-type) ' ...
    ' (slot orbit-inclination) ' ...
    ' (slot orbit-raan) ' ...
    ' (slot instrument-field-of-view#) ' ...
    ' (slot avg-revisit-time-global#) ' ...
    ' (slot avg-revisit-time-tropics#) ' ...
    ' (slot avg-revisit-time-northern-hemisphere#) ' ...
    ' (slot avg-revisit-time-southern-hemisphere#) ' ...
    ' (slot avg-revisit-time-cold-regions#) ' ...
    ' (slot avg-revisit-time-US#) ' ...
   '  )'];
r.eval(call);  

% %% Instrument manifested
% call= ['(deftemplate MANIFEST::Instrument-manifested "Instrument manifested in a mission architecture" ' ...
%     ' (slot instrument-name) ' ...
%     ' (slot mission-architecture)  ' ...
%     ' (slot num-of-sats-per-plane#)  ' ...
%     ' (slot num-of-planes#)  ' ...
%     ' (slot orbit-altitude#) ' ...
%     ' (slot orbit-type) ' ...
%     ' (slot orbit-inclination) ' ...
%     ' (slot instrument-field-of-view#) ' ...
%     ' (slot avg-revisit-time-global#) ' ...
%     ' (slot avg-revisit-time-tropics#) ' ...
%     ' (slot avg-revisit-time-northern-hemisphere#) ' ...
%     ' (slot avg-revisit-time-southern-hemisphere#) ' ...
%     ' (slot avg-revisit-time-cold-regions#) ' ...
%     ' (slot avg-revisit-time-US#) ' ...
%    '  )'];
r.eval(['(bind ?template_definition_clp "' params.template_definition_clp '")']);
r.eval('(batch ?template_definition_clp)');
% %% Synergies
% call = ['(deftemplate SYNERGIES::cross-registered "Declare a set of measurements as cross-registered" ' ...
%     '(multislot measurements) (slot degree-of-cross-registration) (slot platform))'];
% r.eval(call);
% 
% call = ['(deftemplate SYNERGIES::cross-registered-instruments "Declare a set of instruments as cross-registered" ' ...
%     '(multislot instruments) (slot degree-of-cross-registration) (slot platform))'];
% r.eval(call);
% 
% % add rule to go from one type to other
% 
% %% Aggregation
% 
% jess deftemplate AGGREGATION::STAKEHOLDER (slot id) (slot parent) (slot index) (slot satisfaction) (slot satisfied-by) (multislot obj-scores) (slot reason) (multislot weights);
% jess deftemplate AGGREGATION::OBJECTIVE (slot id) (slot index) (slot satisfaction) (slot reason) (multislot subobj-scores) (slot satisfied-by) (slot parent) (multislot weights);
% jess deftemplate AGGREGATION::SUBOBJECTIVE (slot id) (slot index) (slot satisfaction) (multislot attributes) (multislot attrib-scores) (multislot reasons) (slot reason) (slot satisfied-by) (slot parent);
% jess deftemplate AGGREGATION::ATTRIBUTE (slot id) (slot satisfaction) (slot reason) (slot satisfied-by) (slot parent);
% jess deftemplate AGGREGATION::VALUE (slot satisfaction) (slot reason) (multislot weights) (multislot sh-scores);
% 
% 
% %% Explaining the reasoning
% jess deftemplate REASONING::fuzzy-number (slot value) (slot value#) (slot type) (slot id) (multislot interval) (slot unit) (slot explanation);
% 
% call = ['(deftemplate REASONING::partially-satisfied "Requirements that are partially satisfied" (slot subobjective)' ...
%     ' (slot objective) (slot parameter) (slot taken-by) (slot attribute) (slot required) (slot achieved) (slot score))'];
% r.eval(call);
% 
% call = ['(deftemplate REASONING::fully-satisfied "Requirements that are partially satisfied" (slot subobjective)' ...
%     ' (slot objective) (slot parameter) (slot taken-by) (slot score))'];
% r.eval(call);
% 
% call = ['(deftemplate REASONING::stop-improving "Flag to stop improving a measurement through application of synergy rules"' ...
%     ' (slot Measurement))']; 
% r.eval(call);
% 
% call = ['(deftemplate REASONING::architecture-eliminated "Reasons why architecture was eliminated" (slot arch-id) (slot fit)' ...
%     ' (slot arch-str) (slot science) (slot cost) (slot utility) (slot pareto-ranking) (slot programmatic-risk) (slot fairness)' ... 
%     ' (slot launch-risk) (slot reason-id) (slot data-continuity) (slot discounted-value) (slot reason-str))'];
% r.eval(call);
% 
% %% Orbit selection
% r.eval('(deftemplate ORBIT-SELECTION::orbit (slot orb) (slot of-instrument) (slot in-mission) (slot is-type) (slot h) (slot i) (slot e) (slot a) (slot raan) (slot anomaly) (slot penalty-var) )');
% 
% %% For lv selection
% r.eval('(deftemplate ORBIT-SELECTION::launcher (slot lv) (multislot performance) (slot cost) (slot diameter) (slot height) )');
% 
% %% Instrument selection problem
% % Enumeration
% % jess defmodule HARD-CONSTRAINTS;
% jess deftemplate HARD-CONSTRAINTS::SEL-ARCH (multislot selected-instruments) (slot sequence) (slot science) (slot fit)... 
%     (slot cost) (slot utility) (slot data-continuity) (slot pareto-ranking) (slot programmatic-risk) (slot fairness) (slot mutate) (slot improve);
% jess deftemplate HARD-CONSTRAINTS::FIX-INSTRUMENTS (multislot instruments) (slot mask);
% jess deftemplate HARD-CONSTRAINTS::OR-INSTRUMENTS (multislot instruments) (slot mask);
% jess deftemplate HARD-CONSTRAINTS::GROUP-INSTRUMENTS (multislot instruments) (slot mask);
% jess deftemplate HARD-CONSTRAINTS::XOR-INSTRUMENTS (multislot instruments) (slot mask);
% jess deftemplate HARD-CONSTRAINTS::NOT-INSTRUMENTS (multislot instruments) (slot mask);
% jess deftemplate HARD-CONSTRAINTS::SUPPORT-INSTRUMENTS (multislot instruments) (slot mask);
% jess deftemplate HARD-CONSTRAINTS::EXACTLY-N-OUT-OF-K-CONSTRAINT (slot mask) (multislot instruments) (slot N);
% % Search
% % jess defmodule SEARCH-HEURISTICS;
% 
% % Down-selection
% % jess defmodule DOWN-SELECTION;
% jess deftemplate DOWN-SELECTION::MAX-COST (slot max-cost);
% jess deftemplate DOWN-SELECTION::MIN-SCIENCE (slot min-science);
% jess deftemplate DOWN-SELECTION::MIN-PARETO-RANK (slot min-pareto-rank);
% jess deftemplate DOWN-SELECTION::MIN-UTILITY (slot min-utility);
% jess deftemplate DOWN-SELECTION::MAX-PROG-RISK (slot max-programmatic-risk);
% jess deftemplate DOWN-SELECTION::MAX-LAUNCH-RISK (slot max-launch-risk);
% jess deftemplate DOWN-SELECTION::MIN-FAIRNESS (slot min-fairness);
% jess deftemplate DOWN-SELECTION::MIN-DISCOUNTED-VALUE (slot min-discounted-value);
% jess deftemplate DOWN-SELECTION::MIN-DATA-CONTINUITY (slot min-data-continuity);
% jess deftemplate DOWN-SELECTION::MAX-FIT (slot max-fit);
% 
% %% Instrument packaging problem
% % Enumeration
% jess deftemplate HARD-CONSTRAINTS::PACK-ARCH (multislot assignments) (slot str) (slot science) (multislot instrument-orbits) ... 
%     (slot cost) (slot data-continuity) (slot utility) (slot pareto-ranking) (slot programmatic-risk) (slot launch-risk) ...
%     (multislot launch-pack-factors) (slot mutate) (slot improve);
% jess deftemplate HARD-CONSTRAINTS::MAX-SATS (slot max-sats#);
% jess deftemplate HARD-CONSTRAINTS::MAX-INSTRS-PER-SAT (slot max-instruments-per-satellite#);
% jess deftemplate HARD-CONSTRAINTS::TOGETHER-INSTRUMENTS (multislot instruments);
% jess deftemplate HARD-CONSTRAINTS::APART-INSTRUMENTS (multislot instruments);
% jess deftemplate HARD-CONSTRAINTS::ALONE-INSTRUMENTS (multislot instruments);
% jess deftemplate HARD-CONSTRAINTS::FORCE-ORBIT (slot of-instrument) (slot required-orbit);
% 
% jess deftemplate CAPABILITIES::can-measure (slot instrument) (slot in-orbit) (slot orbit-type) (slot orbit-altitude#) (slot data-rate-duty-cycle#) (slot power-duty-cycle#) (slot data-rate-constraint) (slot orbit-inclination) (slot orbit-RAAN) (slot can-take-measurements) (slot reason);
% jess deftemplate CAPABILITIES::resource-limitations (slot mission) (multislot instruments) (slot data-rate-duty-cycle#) (slot power-duty-cycle#) (slot reason); 
% 
% %% Mission scheduling problem
% % Enumeration
% jess deftemplate HARD-CONSTRAINTS::PERMUTING-ARCH (multislot sequence) (slot str) (slot science) (slot data-continuity) (slot discounted-value) ... 
%     (slot cost) (slot utility) (slot pareto-ranking) (slot programmatic-risk) (slot fairness) (slot mutate) (slot improve);
% jess deftemplate HARD-CONSTRAINTS::BEFORE-CONSTRAINT (slot element) (multislot before);
% jess deftemplate HARD-CONSTRAINTS::AFTER-CONSTRAINT (slot element) (multislot after);
% jess deftemplate HARD-CONSTRAINTS::BETWEEN-CONSTRAINT (slot element) (multislot between);
% jess deftemplate HARD-CONSTRAINTS::NOT-BETWEEN-CONSTRAINT (slot element) (multislot not-between);
% 
% jess deftemplate HARD-CONSTRAINTS::BEFORE-DATE-CONSTRAINT (slot element) (multislot before);
% jess deftemplate HARD-CONSTRAINTS::AFTER-DATE-CONSTRAINT (slot element) (multislot after);
% jess deftemplate HARD-CONSTRAINTS::BETWEEN-DATES-CONSTRAINT (slot element) (multislot between);
% jess deftemplate HARD-CONSTRAINTS::NOT-BETWEEN-DATES-CONSTRAINT (slot element) (multislot not-between);
% 
% jess deftemplate HARD-CONSTRAINTS::CONTIGUITY-CONSTRAINT (multislot elements);
% jess deftemplate HARD-CONSTRAINTS::NON-CONTIGUITY-CONSTRAINT (multislot elements);
% jess deftemplate HARD-CONSTRAINTS::SUBSEQUENCE-CONSTRAINT (multislot subsequence);
% 
% jess deftemplate HARD-CONSTRAINTS::BY-BEGINNING-CONSTRAINT (multislot elements);
% jess deftemplate HARD-CONSTRAINTS::BY-MIDDLE-CONSTRAINT (multislot elements);
% jess deftemplate HARD-CONSTRAINTS::BY-END-CONSTRAINT (multislot elements);
% jess deftemplate HARD-CONSTRAINTS::FIX-POSITION-CONSTRAINT (slot element) (slot position);
% jess deftemplate HARD-CONSTRAINTS::NEAR-CONSTRAINT (multislot elements);
% jess deftemplate HARD-CONSTRAINTS::FAR-CONSTRAINT (multislot elements);
% 
% %% Instrument to orbit assignment problem
% 
% jess deftemplate HARD-CONSTRAINTS::ASSIGN-ARCH (multislot assignments) (slot str) (slot science) (slot data-continuity) (slot discounted-value) ... 
%     (slot cost) (slot utility) (slot pareto-ranking) (slot programmatic-risk) (slot fairness) (slot mutate) (slot improve);
% return
