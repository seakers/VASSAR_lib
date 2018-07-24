function precompute_revtimes_stk()
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
fov = 55;

%initiates STK
params = init();
sum = 0;

%hashmap of revtimes will be a sorted list of orbit indices. Empty
%orbits are not included in the sorted list
tmprevtimes = java.util.HashMap;

%each constellation to try is just an array of orbit indices as given by the EOSSDatabase
%norbits + 1 is to account for the empty orbit
%subtract 2 because EOSSDatabase is 0-indexed. So -1 would be an empty
%orbit
orbitIndices = fullfact(ones(1,nSats)*(norbits + 1)) - 2;
orbitIndices = orbitIndices(2:end,:); %reject the empty architecture
%sort indices and find unique architectures
h=waitbar(0,'Sorting out unique architectures to simulate...');
sortedOrbitsIndices = sort(orbitIndices,2);
uniqueArrays = unique(sortedOrbitsIndices,'rows');
%representation of architecture will be a sorted array of the orbit indices
for i= 1 : size(uniqueArrays,1)
    orbits = uniqueArrays(i, uniqueArrays(i,:) >= 0); %non-empty orbits
    if ~tmprevtimes.containsKey(orbits)
        tmprevtimes.put(orbits, []);
    end
    waitbar(i/size(uniqueArrays,1),h,'Finding unique architectures...');
end
close(h)
clear orbitIndices

revtimes = java.util.HashMap;
archs = java.util.ArrayList(tmprevtimes.keySet());
for i=0:archs.size-1;
    tic;
    arch = archs.get(i);
    fprintf('Precomputing arch %d out of %d...\n',i,tmprevtimes.size);
    str = '';
    for j=1:length(arch)
        str = strcat(str, num2str(arch(j)), ':');
    end
    fprintf('Arch: %s\n',str)
    therevtimes = analyze_mixed_constellation(fov, arch ,params);
    revtimes.put(arch, therevtimes);
    
    t = toc;
    sum = sum + t/60;
    remaining = tmprevtimes.size - i;
    fprintf('%.1f min elapsed total (%.1f sec for this iter). %.1f min remaining\n\n',sum,t,remaining*t/60);
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

function params = init()
params.DURATION = 7*24*60*60;% simulate for 7 days (in seconds)
params.TSTEP = 60;% time step is set to 1 minute, this gives us about 95 points per orbit and 20160 points per simulation
params.path= '.\';
params.path_save_results = params.path;
params.LAT_LON_GRANULARITY = 6;
params.delta_raan = 0;
params.MAX_LAT = 90;
params.e = 0;
params.arg_perigee = 0;
remMachine = stkDefaultHost;
params.conid = stkOpen(remMachine);% params structure will be use to call internal function
scenario_name = 'EOCubsats2';
stkNewObj('/','Scenario',scenario_name);% creates scenario
params.scenario_path = ['/Scenario/' scenario_name '/'];% will use this later
stkSetTimePeriodInSec(0, params.DURATION)
stkSetEpoch('2013001.000000', 'YYYYDDD.HHMMSS');
stkSetTimePeriodInSec(0, params.DURATION)
GEO_avg_revisit_time_constraint(15*60,params.DURATION,params.TSTEP);
call = ['SetAnimation ' params.scenario_path ' StartAndCurrentTime UseAnalysisStartTime TimeStep ' num2str(params.TSTEP)];
stkExec(params.conid,call);

stkExec(params.conid,['Parallel ' params.scenario_path ' Configuration ParallelType Local NumberOfLocalCores 4']);
stkExec(params.conid,['Parallel ' params.scenario_path ' ShutdownLocalWorkersOnJobCompletion Off']);
stkExec(params.conid,['Parallel ' params.scenario_path ' AutomaticallyComputeInParallel On']);

% Global Coverage grid
coverage_name = 'GlobalCoverage';
stkNewObj(params.scenario_path, 'CoverageDefinition', coverage_name);% creates coverage definition
params.coverage_path = [params.scenario_path 'CoverageDefinition/' coverage_name '/'];
stkSetCoverageBounds(params.conid, [params.scenario_path 'CoverageDefinition/' coverage_name], -params.MAX_LAT, +params.MAX_LAT);% sets max/min latitude
call = ['Cov ' params.coverage_path ' Grid PointGranularity LatLon ' num2str(params.LAT_LON_GRANULARITY)];
stkExec(params.conid, call);

% US Coverage grid
coverage_name2 = 'RegionalCoverage';
stkNewObj(params.scenario_path, 'CoverageDefinition', coverage_name2);% creates coverage definition
params.coverage_path2 = [params.scenario_path 'CoverageDefinition/' coverage_name2 '/'];
call = ['Cov ' params.coverage_path2 ' Grid AreaOfInterest Custom Region "C:\Program Files (x86)\AGI\STK 10\Data\Shapefiles\Countries\United_States\United_States.shp"'];
stkExec(params.conid, call);
call = ['Cov ' params.coverage_path2 ' Grid PointGranularity LatLon ' num2str(params.LAT_LON_GRANULARITY)];
stkExec(params.conid, call);

stkNewObj(params.scenario_path, 'Constellation', 'MyCons');
params.constel_path = [params.scenario_path 'Constellation/' 'MyCons'];

%set up orekit
orekit.util.OrekitConfig.init(pwd);
utc = org.orekit.time.TimeScalesFactory.getUTC();
params.startDate = org.orekit.time.AbsoluteDate(2013, 1, 1, 00, 00, 00.000, utc);
params.endDate   = org.orekit.time.AbsoluteDate(2013, 1, 8, 00, 00, 00.000, utc);
params.merger = orekit.coverage.access.CoverageAccessMerger;
params.database = 'C:\Users\SEAK1\Nozomi\EOSS\CoverageDatabase';
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

function revtimes = analyze_mixed_constellation(fov, arch, params)
tStart  = 0;
tStop   = params.DURATION;
tStep   = params.TSTEP;

% Add instrument with the right fov to all orbits
% first find the number of occurences in each unique orbit
uniqueOrbits = unique(arch);
count = zeros(length(uniqueOrbits),1);
for i=1:length(uniqueOrbits)
    count(i) = sum(arch == uniqueOrbits(i));
end

globalAccesses = [];
usAccesses = [];

for i = 1:length(uniqueOrbits)
    orbit = eoss.problem.EOSSDatabase.getOrbit(uniqueOrbits(i));
    semimajorAxis = orbit.getSemimajorAxis;
    inc = getInclination(orbit.getInclination, orbit.getAltitude)*pi/180;
    raan = getRAAN(orbit.getRAAN);
    
    for j = 1:count(i)
        anomaly = double((j-1)*2*pi/count(i));% evenly spaced satellites within the plane
        filename = strcat(params.database,filesep,num2str(semimajorAxis),'_', num2str(inc),'_', num2str(raan),'_', num2str(anomaly));
        if(exist(strcat(filename,'_global.dat'),'file') == 0) %if sat has not bee simulated yet
            sat_name = [num2str(uniqueOrbits(i)) '-' num2str(j)];
            stkNewObj(params.scenario_path, 'Satellite', sat_name);
            sat_path = [params.scenario_path 'Satellite/' sat_name];
            
            stkSetPropClassical(sat_path, 'J2Perturbation','J2000',tStart,tStop,tStep,0,semimajorAxis,params.e,inc,params.arg_perigee,raan,anomaly);
            
            %set sensor
            sensor_name = num2str(fov);
            stkNewObj(sat_path, 'Sensor', sensor_name);
            sensor_path = [sat_path '/Sensor/' sensor_name];
            sensor_id = stkSetSensor(params.conid, sensor_path,'Rectangular', fov,fov);
            
            call = ['Chains ' params.constel_path ' Add ' sensor_path];
            stkExec(params.conid, call);
            
            % Assign coverage grid as asset to constellation
            stkSetCoverageAsset(params.conid, params.coverage_path, params.constel_path);
            stkSetCoverageAsset(params.conid, params.coverage_path2, params.constel_path);
            
            stkExec(params.conid,['Cov ' params.coverage_path ' Access ParallelCompute']);
            call = ['Cov ' params.coverage_path ' Access Export "C:\Users\SEAK1\Nozomi\EOSS\CoverageDatabase\global.cvaa"'];
            stkExec(params.conid, call);
            stkExec(params.conid,['Cov ' params.coverage_path2 ' Access ParallelCompute']);
            call = ['Cov ' params.coverage_path2 ' Access Export "C:\Users\SEAK1\Nozomi\EOSS\CoverageDatabase\us.cvaa"'];
            stkExec(params.conid, call);
            
            %convert cvaa files to orekit timeintervalarrays
            satGlobalAccesses = cvaaToOrekitAccesses('C:\Users\SEAK1\Nozomi\EOSS\CoverageDatabase\global.cvaa',params);
            satUSAccesses = cvaaToOrekitAccesses('C:\Users\SEAK1\Nozomi\EOSS\CoverageDatabase\us.cvaa',params);
            orekit.coverage.access.TimeIntervalArray.save(java.io.File(strcat(filename,'_global.dat')),satGlobalAccesses);
            orekit.coverage.access.TimeIntervalArray.save(java.io.File(strcat(filename,'_us.dat')),satUSAccesses);
            
            stkUnload(sat_path);
        else
            satGlobalAccesses = orekit.coverage.access.TimeIntervalArray.load(java.io.File(strcat(filename,'_global.dat')));
            satUSAccesses = orekit.coverage.access.TimeIntervalArray.load(java.io.File(strcat(filename,'_us.dat')));
        end
        
        if isempty(globalAccesses)
            globalAccesses = satGlobalAccesses;
        else
            globalAccesses = params.merger.mergeCoverageDefinitionAccesses(globalAccesses, satGlobalAccesses, false);
        end
        
        if isempty(usAccesses)
            usAccesses = satUSAccesses;
        else
            usAccesses = params.merger.mergeCoverageDefinitionAccesses(usAccesses, satUSAccesses, false);
        end
    end
end

revtimes = java.util.HashMap;
globalStat = orekit.coverage.analysis.CoverageAnalyzer(globalAccesses);
meanGlobalRevTime = globalStat.getMeanGap();
revtimes.put('Global',meanGlobalRevTime);
usStat = orekit.coverage.analysis.CoverageAnalyzer(usAccesses);
meanUSRevTime = usStat.getMeanGap();
revtimes.put('US',meanUSRevTime);
fprintf('Mean revisit times: Global %5f\tUS: %5f\n',meanGlobalRevTime, meanUSRevTime)
end

function accesses = cvaaToOrekitAccesses(filename, params)
fprintf('Converting cvaa %s\n', filename)
earthFrame = org.orekit.frames.FramesFactory.getITRF(org.orekit.utils.IERSConventions.IERS_2003, true);
earth_radius = org.orekit.utils.Constants.WGS84_EARTH_EQUATORIAL_RADIUS;
earthShape = org.orekit.bodies.OneAxisEllipsoid(earth_radius,...
    org.orekit.utils.Constants.WGS84_EARTH_FLATTENING, earthFrame);

accesses = java.util.HashMap;
fid = fopen(filename,'r');
np = 0;
while(~feof(fid))
    tline = fgetl(fid);
    %point update
    point_update = regexp(tline,'PointNumber:\s+(?<nr>\d+)','tokens');
    if ~isempty(point_update)
        np = np + 1;
    end
    
    % point update
    latlon_update = regexp(tline,'Lat:\s+(?<lat>[-+]*\d+\.\d+[eE][-+]*\d+)','tokens');
    if ~isempty(latlon_update)
        lat = str2double(latlon_update{1});
        tline = fgetl(fid);
        latlon_update = regexp(tline,'Lon:\s+(?<lon>[-+]*\d+\.\d+[eE][-+]*\d+)','tokens');
        lon = str2double(latlon_update{1});
        covPoint = orekit.object.CoveragePoint(earthShape, org.orekit.bodies.GeodeticPoint(lat,lon,0.), num2str(np));
        accesses.put(covPoint,orekit.coverage.access.TimeIntervalArray(params.startDate, params.endDate));
        continue;
    end
    % new point
    access = regexp(tline,'(?<i>\d+)\s+(?<t0>-*\d+\.\d+[eE][-+]*\d+)\s+(?<t1>-*\d+\.\d+[eE][-+]*\d+)','names');
    if ~isempty(access)
        accesses.get(covPoint).addRiseTime(str2double(access.t0));
        accesses.get(covPoint).addSetTime(str2double(access.t1));
    end
end
fclose(fid);

end
