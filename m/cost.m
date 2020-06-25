function c = cost(sa, inc, imass, ipower, idata, lifetime, launchcost, nsat)

%Inputs:
%sa = semimajor axis [m]
%inc = inclination [deg]
%imass = instrument mass [kg]
%ipower = instrument power [W]
%idata = instrument data rate []
%lifetime = lifetime of the mission yrs
%launch cost = launch cost
%nsat = number of satellites for learning curve
%
%OUTPUT:
%c = cost of a single satellite

%check input
if(sa < 6371000)
    error('Expected semimajor axis to be larger than Earth radius (63710000 m). Found %f', sa);
end

%load jar file
javaaddpath(['.',filesep,'dist',filesep,'EOSS.jar']);

try
    
    %define instrument
    payload = java.util.ArrayList;
    prop = java.util.HashMap;
    prop.put('Technology-Readiness-Level','10');
    prop.put('developed-by','DOM');
    prop.put('mass#',java.lang.String(num2str(imass)));
    prop.put('characteristic-power#',java.lang.String(num2str(ipower)));
    prop.put('average-data-rate#',java.lang.String(num2str(idata)));
    inst = eoss.problem.Instrument('inst', 0, prop);
    payload.add(inst);
    
    %define orbit
    orbTypes = javaMethod('values','eoss.problem.Orbit$OrbitType');
    orb = eoss.problem.Orbit('orb',orbTypes(1), sa, java.lang.String(num2str(inc)), '0', 0, 0, 0); 
    
    %define spacecraft and size components
    sc = eoss.spacecraft.Spacecraft('sat',payload);
    scd = eoss.spacecraft.SpacecraftDesigner;
    scd.designSpacecraft(sc, orb, lifetime);
    
    %Compute data rate per orbit with 20% overhead (GByte/orbit) 
    perOrbit = (idata * 1.2 * eoss.problem.Orbits.period(orb)) / (1024 * 8);
    sc.setProperty('sat-data-rate-per-orbit#',java.lang.String(num2str(perOrbit)));
    
    c = eoss.problem.evaluation.CostModel.lifeCycleCost(sc, lifetime, launchcost, nsat);
catch
    
    c = -1;
end

%unload jar file
clear payload prop inst orb sc scd orbTypes
javarmpath(['.',filesep,'dist',filesep,'EOSS.jar']);