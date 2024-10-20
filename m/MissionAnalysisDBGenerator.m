%% MissionAnalysisDBGenerator.m
% clear all;

%% Simulation parameters
LOAD_INTERMEDIATE_RESULTS = false;

params.DURATION = 7*24*60*60;% simulate for 7 days (in seconds)
params.TSTEP = 60;% time step is set to 1 minute, this gives us about 95 points per orbit and 20160 points per simulation
params.MAX_LAT = 90;% this is the maximum latitude (north and south) that is relevant for the analysis
% params.path_save_results = 'C:\Users\dani\Documents\My Dropbox\RBES\results';% C:\Users\Ana-Dani\Dropbox\RBES
params.path_save_results = 'C:\Users\Ana-Dani\Dropbox\RBES\results';% C:\Users\Ana-Dani\Dropbox\RBES
params.scenario_name = 'Cubesat';
params.scenario_path = ['/Scenario/' params.scenario_name '/'];% will use this later
params.GRANULARITY = 2;% in deg, lat-lon
params.headers = {'nsat_per_plane'	'nplanes'	'altitude'	'inclination'	'ltan'	'sensor_fov'	'avg_revisit_time'	'avg_revisit_time_tropics'	'avg_revisit_time_NH'	'avg_revisit_time_SH'	'avg_revisit_time_cold_regions'	'avg_revisit_time_US'};

%% Sensor parameters
params.sensor.type = 'Rectangular';% 'Rectangular' , 'SimpleCone' , or 'HalfPower'
params.sensor.FOV_x = 45;% in deg
params.sensor.FOV_y = 20;% in deg, only for rectangular
params.sensor.pointing = 'Fixed'; % 'Spinning' or 'Fixed' 

%% Simulation STK variables 
nsat_vec = [1 2 3 4];
nplane_vec = [1 2 3 4];
h_vec = [400 500 600 700 800];
i_vec = [30 66 90 100];
LTAN_vec = [6 22.5 13.5];% DD AM PM


levels = [length(nsat_vec) length(nplane_vec) length(h_vec) length(i_vec) length(LTAN_vec)];
indexes = fullfact(levels);
archs = zeros(size(indexes));

%% Init STK
agiInit;
remMachine = stkDefaultHost;
params.conid = stkOpen(remMachine);% params structure will be use to call internal function

stkNewObj('/','Scenario',params.scenario_name);% creates scenario
stkSetTimePeriodInSec(0, params.DURATION)
call = ['SetAnimation ' params.scenario_path ' TimeStep ' num2str(params.TSTEP)];
stkExec(params.conid,call);

%% Loop STK simulations


if LOAD_INTERMEDIATE_RESULTS
    load intermediate_results;
%     first = find(cellfun(@isempty,results),1);
    first = length(results) + 1;
    if isempty(results)
        first = 1;
    end
else
    
    results = cell(narchs,1);
    first = 1;
end
narchs = size(archs,1);
for i = first:narchs
    fprintf('Simulating constellation %d from %d\n',i,narchs);
    NSAT = nsat_vec(indexes(i,1));
    NPLANE = nplane_vec(indexes(i,2));
    ALT = h_vec(indexes(i,3));
    INC = i_vec(indexes(i,4));
    RAAN = LTAN_to_RAAN(LTAN_vec(indexes(i,5)));
    if INC == 100 %%SSO
        INC = SSO_h_to_i(ALT);
    end
    archs(i,:) = [NSAT NPLANE ALT INC RAAN];
    tmp_res = analyze_constellation(NSAT, NPLANE, ALT, INC, RAAN, params.sensor, params);
    results{i} = tmp_res;
    save intermediate_results archs results;
end
write_to_excel = compile_mission_analysis_results(results);

%% SAVE
savepath = [params.path_save_results '\'];
tmp = clock();
hour = num2str(tmp(4));
min = num2str(tmp(5));
label = 'EOCubesats_results';
filesave = [savepath label '-' date '-' hour '-' min];
save(filesave,'results','archs','params','write_to_excel');
   
