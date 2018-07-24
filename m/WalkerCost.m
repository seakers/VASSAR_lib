M = csvread('/Users/nozomihitomi/Dropbox/EOSS/revisitTime5_1to50.csv',1,0);
A = M(:,1);
I = M(:,2);
T = M(:,3);
P = M(:,4);
F = M(:,5);
Rev = M(:,6);
Resp = M(:,7);

instrumentMass = 240; %kgs
intrumentPower = 215; %watts
dataRate = 1520; %kbps
lifetime = 15; %years

C = zeros(size(T,1),1);
h = waitbar(0);

%initialize Java stuffs
javaaddpath(['.',filesep, 'dist',filesep,'EOSS.jar']);
path = cd;
orekit.util.OrekitConfig.init(path);

%set up instrument and LV database
%define instrument
payload = java.util.ArrayList;
prop = java.util.HashMap;
prop.put('Technology-Readiness-Level','10');
prop.put('developed-by','DOM');
prop.put('mass#',java.lang.String(num2str(instrumentMass)));
prop.put('characteristic-power#',java.lang.String(num2str(intrumentPower)));
prop.put('average-data-rate#',java.lang.String(num2str(dataRate)));
prop.put('dimension-x#',java.lang.String(num2str(0))); %these dimensions are meaningless and aren't used in cost
prop.put('dimension-y#',java.lang.String(num2str(0)));
prop.put('dimension-z#',java.lang.String(num2str(0)));
inst = eoss.problem.Instrument('inst', 0, prop);
payload.add(inst);

%load in LV database
db = eoss.problem.EOSSDatabase.getInstance();
eoss.problem.EOSSDatabase.loadLaunchVehicles(java.io.File(strcat(path,filesep,'problems',...
    filesep,'climateCentric',filesep,'config',filesep,'candidateLaunchVehicles.xml')));
%create architecture evaluator
reqType = javaMethod('values','eoss.problem.evaluation.RequirementMode');
archEval = eoss.problem.evaluation.ArchitectureEvaluator(strcat(path,filesep,'problems',...
    filesep,'climateCentric'),reqType(3),false,[]);

for i=1:size(T,1)
    %launch vehicle selection
    C(i) = walkerConstellationCost(T(i), P(i), A(i), payload, lifetime,archEval);
    waitbar(i/size(T,1),h,sprintf('%f%% complete: %d out of %d',i*100/size(T,1),i,size(T,1)));
end
close(h);
clear payload prop db reqType archEval inst
javarmpath(['.',filesep, 'dist',filesep,'EOSS.jar']);
save walkerCost.mat