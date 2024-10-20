%% Initialization
javaaddpath('C:\Program Files\MATLAB\R2010b\java\jarext\jess.jar');
r = jess.Rete();
r.reset();

%% Define templates
r.eval('(deftemplate Measurement (slot parameter))');
r.eval('(deftemplate Instrument (slot type))');


%% Global variables
% Define global variable
d = Defglobal('*subobjective-C1-1*',Value(0,RU.FLOAT));
r.addDefglobal(d);
% Set value of global variable

% Get value of global variable
c = r.getGlobalContext();
s = r.eval('?*subobjective-C1-1*');
science = s.numericValue(c);

%% Define rules
% r.eval('(defrule GPS-radio-occultation-objective "Objective C1 is totally satisfied if GPS radio occultation measurements exist" (Measurement {parameter == GPS}) => (printout t "C1 objective fully satisfied" crlf))');
r.eval('(batch "rules_objective_climate1.clp")');

%% Define facts
f = Fact('Measurement', r);
f.setSlotValue('parameter', Value('CO2', RU.STRING));

%% Assert facts
% jess_command = '(assert (Measurement (parameter GPS)))';
% r.eval(jess_command);
r.assertFact(f);

%% Run
r.run();