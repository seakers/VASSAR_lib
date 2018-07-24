function precompute_revtimes_orekit()
% precompute_revtimes.m
%
% This function computes an approximate revisit time of all possible orbit
% combinations. Current directory should be set to the parent EOSS directory
%

%load EOSS jar file
eoss_java_init();
addpath 'C:\Users\SEAK1\Nozomi\OREKIT\matlab';
origin = cd('C:\Users\SEAK1\Nozomi\OREKIT');
orekit_init();
cd(origin)

%inspects the candidate orbits
eoss.problem.EOSSDatabase.getInstance;
eoss.problem.EOSSDatabase.loadOrbits(java.io.File(strcat(cd, filesep, 'problems', filesep, 'climateCentric', filesep, 'config', filesep, 'candidateOrbits.xml')));
norbits = eoss.problem.EOSSDatabase.getNumberOfOrbits;

%problem settings
nSats = 5;
fov = 55*pi/180; %in radians

%initiates orekit scenario parameters
params = init_scenario();
sum = 0;

%hashmap of revtimes will be a sorted list of orbit indices. Empty
%orbits are not included in the sorted list
revtimes = java.util.HashMap;

%each constellation to try is just an array of orbit indices as given by the EOSSDatabase
%norbits + 1 is to account for the empty orbit
%subtract 2 because EOSSDatabase is 0-indexed. So -1 would be an empty
%orbit
orbitIndices = fullfact(ones(1,nSats + 1)*norbits) - 2;
narch = size(orbitIndices,1);
for i=1:narch
    tic;
    
    %begin simulation
    fprintf('Precomputing arch %d out of %d...\n',i,narch);
    orbits = orbitIndices(i, orbitIndices(i,:) >= 0); %non-empty orbits
    if isempty(orbits)
        continue;
    end
    
    sortedOrbits = sort(orbits);
    
    if ~revtimes.containsKey(sortedOrbits)
        therevtimes = analyzeConstellation(fov, orbits ,params);
        revtimes.put(sortedOrbits, therevtimes);
    end
    
    t = toc;
    sum = sum + t/60;
    done = i;
    all = narch;
    remaining = all - done;
    fprintf('%.1f min elapsed total (%.1f sec for this iter). %.1f min remaining\n',sum,t,remaining*t/60);
end
save revtimes revtimes
fos = java.io.FileOutputStream('revtimes.dat');
oos = java.io.ObjectOutputStream(fos);
oos.writeObject(revtimes);
oos.close;
fos.close;

%unload EOSS jar file
eoss_java_end();

end

function num = getInclination(str, h_km)
if strcmp(str,'SSO')
    num = SSO_h_to_i(h_km);
elseif strcmp(str,'polar')
    num = 90;
elseif strcmp(str,'ISS')
    num = 51.6;
elseif strcmp(str,'tropical')
    num = 30;
elseif strcmp(str,'equat')
    num = 0;
else
    error('Unknown inclination');
end
end

function num = getRAAN(raan)
offset = 1.7595;%  ok for Jan 1 2013
if strcmp(raan, 'AM')
    num = offset + 7.5*pi/12;
elseif strcmp(raan, 'PM')
    num = offset + 13.5*pi/12;
elseif strcmp(raan, 'DD')
    num = offset + 6*pi/12;
elseif strcmp(raan, 'NA')
    num = 0.0;
else
    error('raan unknown');
end
end



function params = init_scenario()
orekit.util.OrekitConfig.init(pwd);

params.utc = org.orekit.time.TimeScalesFactory.getUTC();
params.startDate = org.orekit.time.AbsoluteDate(2013, 1, 1, 00, 00, 00.000, params.utc);
params.endDate   = org.orekit.time.AbsoluteDate(2013, 1, 8, 00, 00, 00.000, params.utc);

params.mu = org.orekit.utils.Constants.EGM96_EARTH_MU; % gravitation coefficient

%must use these frames to be consistent with STK
earthFrame = org.orekit.frames.FramesFactory.getITRF(org.orekit.utils.IERSConventions.IERS_2003, true);
params.inertialFrame = org.orekit.frames.FramesFactory.getEME2000();

earth_radius = org.orekit.utils.Constants.WGS84_EARTH_EQUATORIAL_RADIUS;
params.earthShape = org.orekit.bodies.OneAxisEllipsoid(earth_radius,...
    org.orekit.utils.Constants.WGS84_EARTH_FLATTENING, earthFrame);
end


function revtimes = analyzeConstellation(fov, arch, params)
%define instruments
fieldOfView = orekit.object.fieldofview.NadirRectangularFOV(fov,fov,0, params.earthShape);
inst = orekit.object.Instrument('view1',fieldOfView,0,0);

% Add instrument with the right fov to all orbits
% first find the number of occurences in each unique orbit
uniqueOrbits = unique(arch);
count = zeros(length(uniqueOrbits),1);
for i=1:length(uniqueOrbits)
    count(i) = sum(arch == uniqueOrbits(i));
end
satellites = java.util.ArrayList;
for i = 1:length(uniqueOrbits)
    orbit = eoss.problem.EOSSDatabase.getOrbit(uniqueOrbits(i));
    a = orbit.getSemimajorAxis;
    e = 0;
    inc = getInclination(orbit.getInclination, orbit.getAltitude)*pi/180;
    pa = 0;
    raan = getRAAN(orbit.getRAAN);
    
    for j = 1:count(i)
        sat_name = [num2str(i) '-' num2str(j)];
        ma = double((j-1)*2*pi/count(i));% evenly spaced satellites within the plane
        
        orbit = org.orekit.orbits.KeplerianOrbit(a, e, inc, pa, raan, ma,...
            org.orekit.orbits.PositionAngle.MEAN, params.inertialFrame,...
            params.startDate, params.mu);
        
        sat = orekit.object.Satellite(sat_name, orbit);
        sat.addInstrument(inst);
        satellites.add(sat);
    end
end

%create constellation
constel = orekit.object.Constellation('constel',satellites);

%create set of coverage definitions
covDefs = java.util.HashSet;
% Global Coverage grid
globalDef = orekit.object.CoverageDefinition('global', orekit.STKGRID.getPoints6(), params.earthShape);
globalDef.assignConstellation(constel);
covDefs.add(globalDef);
% Regional Coverage grid
usDef = orekit.object.CoverageDefinition('US', orekit.USGrid.getPoints6(), params.earthShape);
usDef.assignConstellation(constel);
covDefs.add(usDef);

%set propagator
pf = orekit.propagation.PropagatorFactory(orekit.propagation.PropagatorType.J2, org.orekit.orbits.OrbitType.KEPLERIAN);

%create scenario
scen = orekit.scenario.Scenario2('scen1', params.startDate, params.endDate, params.utc,...
    params.inertialFrame, pf, covDefs, true,true, [], 1);

%run scenario
scen.call();

%extract average revtimes
revtimes = java.util.HashMap;
accesses = scen.getFinalAccesses;
% global stat
% globalStat = orekit.coverage.analysis.CoverageAnalyzer(accesses.get(globalDef));
% revtimes.put('Global',globalStat.getMeanGap());
% regional stat
usStat = orekit.coverage.analysis.CoverageAnalyzer(accesses.get(usDef));
revtimes.put('US',usStat.getMeanGap());
end