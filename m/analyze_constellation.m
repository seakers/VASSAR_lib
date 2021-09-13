function results = analyze_constellation(NSAT, NPLANES, ALTITUDE, INCIDENCE, RAAN, sensor, params)
conid = params.conid;

%% Unimportant parameters
params.sensor_name = 'sensor';
params.sat_name = 'Sat';
params.sat_path = [params.scenario_path '/Satellite/' params.sat_name '/'];
params.sensor_path = [params.sat_path '/Satellite/' params.sat_name '/'];

%% Sensor parameters
FOV_x = sensor.FOV_x;
FOV_y = sensor.FOV_y;

%% SET UP CONSTELLATION IF CONID NOT PROVIDED
scenario_path = params.scenario_path;
scenario_name = params.scenario_name;
% 
% if conid == -1
%     agiInit;
%     remMachine = stkDefaultHost;
%     conid = stkOpen(remMachine);
%     path = 'C:\Program Files (x86)\AGI\STK 9';
%     conid = stkOpen(remMachine);
% 
%     % create a scenario
%     stkNewObj('/','Scenario',params.scenario_name);
%     stkSetTimePeriodInSec(0, params.DURATION)
% end

dtr     = pi/180;
tStart  = 0;
tStop   = params.DURATION;
tStep   = params.TSTEP;
Re      = 6378;
h       = ALTITUDE;
semimajorAxis = (Re + h)*1000;
inc     = INCIDENCE*dtr;
raan    = RAAN*dtr;
stkSetAnimationTimeStep(params.conid,params.scenario_path,tStep);
NSAT_PER_PLANE = NSAT;
% NSAT = NSAT_PER_PLANE*NPLANE;

stkNewObj(scenario_path, 'Satellite', params.sat_name);
stkSetPropClassical(params.sat_path, ...
    'J2Perturbation','J2000',tStart,tStop,tStep,0,semimajorAxis,0.0,inc,0.0,raan,0);
% add a sensor to the satellite
sensor_name = params.sensor_name;
stkNewObj(['/Scenario/' scenario_name '/Satellite/Sat/'], 'Sensor', sensor_name);

% set the satellite sensor
stkSetSensor(conid, ...
                 ['/Scenario/' scenario_name '/Satellite/Sat/Sensor/' sensor_name], ...
                 sensor.type, FOV_x, FOV_y);
             
% spinning sensors
if strcmp(sensor.pointing,'Spinning')             
    call = ['Point ' params.scenario_path 'Satellite/' params.sat_name '/Sensor/' sensor_name ' ' sensor.pointing ' ' ...
        num2str(sensor.spin_az) ' ' num2str(sensor.spin_az) ' ' num2str(sensor.spin_cone_angle) ' ' sensor.scan_method ' ' ...
        num2str(sensor.scan_rate) ' ' num2str(sensor.scan_offset)];
    stkExec(conid, call);
end

% Create Walker constellation
call = ['Walker /Scenario/' scenario_name '/Satellite/Sat ' num2str(NPLANES) ' ' num2str(NSAT_PER_PLANE) ' ' num2str(NPLANES-1)  ' 180.0 Yes ConstellationName MyConst'];
stkExec(conid, call);

constel_path = ['/Scenario/' scenario_name '/Constellation/MyConst'];
        
stkUnload(['/Scenario/' scenario_name '/Satellite/Sat']);

for p = 1:NPLANES
    for s = 1:NSAT_PER_PLANE
        sat_name = ['Sat' num2str(p) num2str(s)];
        
        % assign sensor to constellation and remove satellite
        call = ['Chains ' constel_path ' Add ' 'Satellite/' sat_name '/Sensor/' sensor_name];
        call2 = ['Chains ' constel_path ' Remove ' 'Satellite/' sat_name]; 
        stkExec(conid, call);
        stkExec(conid, call2);
    end
end

%% COVERAGE CALCULATIONS

% add a coverage definition
coverage_name = 'Coverage1';
stkNewObj(['/Scenario/' scenario_name '/'], 'CoverageDefinition', coverage_name);
coverage_path = ['/Scenario/' scenario_name '/CoverageDefinition/' coverage_name '/'];

% set latitude bounds on coverage definition
% stkSetCoverageBounds(conid, '/Scenario/Cubesats1/CoverageDefinition/Coverage1', -80, 80);

call = ['Cov ' coverage_path ' Grid Definition LatBounds ' num2str(-params.MAX_LAT) ' ' num2str(+params.MAX_LAT) ' PointGranularity LatLon ' num2str(params.GRANULARITY)];
stkExec(conid, call);
call = ['Cov ' coverage_path ' Grid PointGranularity LatLon ' num2str(params.GRANULARITY)];
stkExec(params.conid,call);

% assign constellation as asset to coverage definition
stkSetCoverageAsset(conid, coverage_path, constel_path);

% -------------------------------------------------------------------------
% Create Figure of Merit: Max Revisit Time
% -------------------------------------------------------------------------
FOM_name1 = 'MaxRevisit_Time';
stkNewObj(coverage_path, 'FigureOfMerit', FOM_name1);
FOM_path1 = [coverage_path 'FigureOfMerit/' FOM_name1 '/'];
% stkSetCoverageFOM(conid, FOM_path1, 'RevisitTime');
call = ['FOMDefine ' FOM_path1 ' ' 'Definition RevisitTime Compute Maximum'];
stkExec(conid, call);

% -------------------------------------------------------------------------
% Create Figure of Merit: Average Revisit Time
% -------------------------------------------------------------------------
FOM_name3 = 'Avg_Revisit_Time';
stkNewObj(coverage_path, 'FigureOfMerit', FOM_name3);
FOM_path3 = [coverage_path 'FigureOfMerit/' FOM_name3 '/'];
% stkSetCoverageFOM(conid, FOM_path1, 'RevisitTime');
call = ['FOMDefine ' FOM_path3 ' ' 'Definition RevisitTime Compute Average'];
stkExec(conid, call);

% Access calculation
stkComputeAccess2(conid,coverage_path);

% % Time to 100% coverage
% [cov_data, cov_names] = stkReport(coverage_path, 'Percent Coverage');
% time = stkFindData(cov_data{2}, 'Time');             % # of seconds past start time
% cov  = stkFindData(cov_data{2}, '% Accum Coverage'); % accumlated coverage
% coverage_time = NaN;
% for i = 1:length(cov)
%     if cov(i) >= 95
%         coverage_time = time(i);
%     break;
%     end
% end
% 
% % Percent coverage at the end of simulation period
% final_cov = cov(end);

%% Reports
% Max Revisit time
[rt_data, rt_names] = stkReport(FOM_path1, 'Value By Grid Point');
rt_value1 = stkFindData(rt_data{3}, 'FOM Value');    % revisit time by grid point
% max_revisit_time = max(rt_value);
% mean_revisit_time = mean(rt_value);


% Avg Revisit time
[rt_data, rt_names] = stkReport(FOM_path3, 'Value By Grid Point');
rt_value3 = stkFindData(rt_data{3}, 'FOM Value');    % revisit time by grid point
% max_revisit_time = max(rt_value);
% mean_revisit_time = mean(rt_value);
lat = stkFindData(rt_data{3}, 'Latitude')*180/pi;
lon = stkFindData(rt_data{3}, 'Longitude')*180/pi - 180;

%% Results

results.max_revisit_times = rt_value1./3600;
results.longitudes = lon;
results.latitudes = lat;
results.avg_revisit_times = rt_value3./3600;

ind_polar = abs(results.latitudes) > 60 ;
results.avg_polar = mean(results.avg_revisit_times(ind_polar));
results.max_polar = mean(results.max_revisit_times(ind_polar));

ind_trop = abs(results.latitudes) < 30 ;
results.avg_trop = mean(results.avg_revisit_times(ind_trop));
results.max_trop = mean(results.max_revisit_times(ind_trop));

ind_NH = results.latitudes > 30 & results.latitudes < 60;
results.avg_NH = mean(results.avg_revisit_times(ind_NH));
results.max_NH = mean(results.max_revisit_times(ind_NH));

ind_SH = results.latitudes < -30 & results.latitudes > -60;
results.avg_SH = mean(results.avg_revisit_times(ind_SH));
results.max_SH = mean(results.max_revisit_times(ind_SH));

ind_US = results.latitudes < 50 & results.latitudes > 25 & results.longitudes > -125 & results.longitudes < -65 ;
results.avg_US = mean(results.avg_revisit_times(ind_US));
results.max_US = mean(results.max_revisit_times(ind_US));

results.avg_global = mean(results.avg_revisit_times);
results.max_global = mean(results.max_revisit_times);

results.all_avg_rev_times = [NSAT NPLANES ALTITUDE INCIDENCE RAAN FOV_x results.avg_global results.avg_trop results.avg_NH results.avg_SH results.avg_polar results.avg_US];
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