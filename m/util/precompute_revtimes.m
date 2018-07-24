function precompute_revtimes()
% precompute_revtimes.m
%
% This function computes an approximate revisit time of all possible orbit
% combinations. Current directory should be set to the parent EOSS directory
%

%load EOSS jar file
eoss_java_init();

%inspects the candidate orbits
eoss.problem.EOSSDatabase.getInstance;
eoss.problem.EOSSDatabase.loadOrbits(java.io.File(strcat(cd, filesep, 'problems', filesep, 'climateCentric', filesep, 'config', filesep, 'candidateOrbits.xml')));
norbits = eoss.problem.EOSSDatabase.getNumberOfOrbits;

%problem settings
nSats = 5;
fov = 55;

%initiates STK
stk_params = init_STK();
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
        therevtimes = analyze_mixed_constellation(fov, orbits ,stk_params);
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

function params = init_STK()
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

function revtimes = analyze_mixed_constellation(fov, arch, stk_params)
% Global Coverage grid
coverage_name = 'GlobalCoverage';
stkNewObj(stk_params.scenario_path, 'CoverageDefinition', coverage_name);% creates coverage definition
coverage_path = [stk_params.scenario_path 'CoverageDefinition/' coverage_name '/'];
stkSetCoverageBounds(stk_params.conid, [stk_params.scenario_path 'CoverageDefinition/' coverage_name], -stk_params.MAX_LAT, +stk_params.MAX_LAT);% sets max/min latitude
call = ['Cov ' coverage_path ' Grid PointGranularity LatLon ' num2str(stk_params.LAT_LON_GRANULARITY)];
stkExec(stk_params.conid, call);

% Create Figure of Merit: Average Revisit Time
FOM_name1 = 'Avg_Revisit_Time';
stkNewObj(coverage_path, 'FigureOfMerit', FOM_name1);
FOM_path1 = [coverage_path 'FigureOfMerit/' FOM_name1 '/'];
call = ['FOMDefine ' FOM_path1 ' ' 'Definition RevisitTime Compute Average'];
stkExec(stk_params.conid, call);

% US Coverage grid
coverage_name2 = 'RegionalCoverage';
stkNewObj(stk_params.scenario_path, 'CoverageDefinition', coverage_name2);% creates coverage definition
coverage_path2 = [stk_params.scenario_path 'CoverageDefinition/' coverage_name2 '/'];
call = ['Cov ' coverage_path2 ' Grid AreaOfInterest Custom Region "C:\Program Files (x86)\AGI\STK 10\Data\Shapefiles\Countries\United_States\United_States.shp"'];
stkExec(stk_params.conid, call);

call = ['Cov ' coverage_path2 ' Grid PointGranularity LatLon ' num2str(stk_params.LAT_LON_GRANULARITY)];
stkExec(stk_params.conid, call);

% Create Figure of Merit: Average Revisit Time
FOM_name2 = 'Avg_Revisit_Time';
stkNewObj(coverage_path2, 'FigureOfMerit', FOM_name2);
FOM_path2 = [coverage_path2 'FigureOfMerit/' FOM_name2 '/'];
call = ['FOMDefine ' FOM_path2 ' ' 'Definition RevisitTime Compute Average'];
stkExec(stk_params.conid, call);

stkNewObj(stk_params.scenario_path, 'Constellation', 'MyCons');
constel_path = [stk_params.scenario_path 'Constellation/' 'MyCons'];

tStart  = 0;
tStop   = stk_params.DURATION;
tStep   = stk_params.TSTEP;

% Add instrument with the right fov to all orbits
% first find the number of occurences in each unique orbit
uniqueOrbits = unique(arch);
count = zeros(length(uniqueOrbits),1);
for i=1:length(uniqueOrbits)
    count(i) = sum(arch == uniqueOrbits(i));
end

for i = 1:length(uniqueOrbits)
    orbit = eoss.problem.EOSSDatabase.getOrbit(uniqueOrbits(i));
    semimajorAxis = orbit.getSemimajorAxis;
    inc = getInclination(orbit.getInclination, orbit.getAltitude)*pi/180;
    raan = getRAAN(orbit.getRAAN);
    
    for j = 1:count(i)
        sat_name = [num2str(i) '-' num2str(j)];
        stkNewObj(stk_params.scenario_path, 'Satellite', sat_name);
        sat_path = [stk_params.scenario_path 'Satellite/' sat_name];
        anomaly = double((j-1)*2*pi/count(i));% evenly spaced satellites within the plane
        stkSetPropClassical(sat_path, 'J2Perturbation','J2000',tStart,tStop,tStep,0,semimajorAxis,stk_params.e,inc,stk_params.arg_perigee,raan,anomaly);
        
        %set sensor
        sensor_name = num2str(fov);
        stkNewObj(sat_path, 'Sensor', sensor_name);
        sensor_path = [sat_path '/Sensor/' sensor_name];
        sensor_id = stkSetSensor(stk_params.conid, sensor_path,'Rectangular', fov,fov);
        
        call = ['Chains ' constel_path ' Add ' sensor_path];
        stkExec(stk_params.conid, call);
    end
end

% Assign coverage grid as asset to constellation
stkSetCoverageAsset(stk_params.conid, coverage_path, constel_path);
stkSetCoverageAsset(stk_params.conid, coverage_path2, constel_path);

call = ['CovAccess ' coverage_path ' Compute ' ''];
stkExec(stk_params.conid, call);

call = ['CovAccess ' coverage_path2 ' Compute ' ''];
stkExec(stk_params.conid, call);

% Global coverage
% CDF Revisit time
[rt_data, ~] = stkReport(coverage_path, 'Gap Duration');
cdf.over = stkFindData(rt_data{4},'% Over');
cdf.under = stkFindData(rt_data{4},'% Under');
cdf.duration = stkFindData(rt_data{4},'Duration');

times = cdf.duration;
pctgs = cdf.under;
pctgs = pctgs./100;
mean = 0;
old = 0;
for j = 1:length(pctgs)
    mean = mean + (pctgs(j)-old)*times(j);
    old = pctgs(j);
end
avg_rev_time_global = mean/3600;

% Regional coverage
% CDF Revisit time
[rt_data2, ~] = stkReport(coverage_path2, 'Gap Duration');
cdf2.over = stkFindData(rt_data2{4},'% Over');
cdf2.under = stkFindData(rt_data2{4},'% Under');
cdf2.duration = stkFindData(rt_data2{4},'Duration');

times2 = cdf2.duration;
pctgs2 = cdf2.under;
pctgs2 = pctgs2./100;
mean2 = 0;
old2 = 0;
for j = 1:length(pctgs2)
    mean2 = mean2 + (pctgs2(j)-old2)*times2(j);
    old2 = pctgs2(j);
end
avg_rev_time_US = mean2/3600;
revtimes = java.util.HashMap;
revtimes.put('Global',avg_rev_time_global);
revtimes.put('US',avg_rev_time_US);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean STK for next architecture
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
objects = stkObjNames;
stkUnload(objects{3});
objects = stkObjNames;

for i = length(objects):-1:2
    stkUnload(objects{i});
end
end