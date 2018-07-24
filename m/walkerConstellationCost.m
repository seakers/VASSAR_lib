function c = walkerConstellationCost(t, p, sa, payload, life, archEvaluator)
%costs out the entire walker architecture
%includes lifecycle cost of each satellite and required launch vehicles to
%deploy the architecture
%
%Inputs:
%t = number of satellites
%p = number of planes
%sa = semimajor axis [m]
%payload = Collections of Instruments
%idata = instrument data rate [KBs per second]
%life = lifetime of the mission yrs
%
%OUTPUT:
%c = cost of a walker

%check input
if(sa < 6371000)
    error('Expected semimajor axis to be larger than Earth radius (63710000 m). Found %f', sa);
end

%create missions
satsPerPlane = t/p;
missionList = java.util.ArrayList();

for i=1:p
    map = java.util.HashMap();
    for j=1:satsPerPlane
        
        %define orbit
        orbTypes = javaMethod('values','eoss.problem.Orbit$OrbitType');
        orb = eoss.problem.Orbit(strcat('orb_',num2str(i)),orbTypes(1), sa, 'ISS', '0', 0, 0, 0);
        
        %define spacecraft
        sc = eoss.spacecraft.Spacecraft(strcat('sat_',num2str(j+(satsPerPlane*(i-1)))),payload);
        
        map.put(sc,orb);
    end
    missionBuilder = javaObject('eoss.problem.Mission$Builder',num2str(i),map);
    missionBuilder.lifetime(life);
    missionList.add(missionBuilder.build);
end
archEvaluator.assertMissions(missionList);
c = archEvaluator.cost(missionList);
