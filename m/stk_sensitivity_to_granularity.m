%% stk_sensitivity_to_granularity.m
RE = 6378;
granularities = [2 1.5 1 0.5 0.1];
dx_equator = RE.*granularities;

params.DURATION = 7*24*60*60;% simulate for 7 days (in seconds)
params.TSTEP = 60;% time step is set to 1 minute, this gives us about 95 points per orbit and 20160 points per simulation
params.MAX_LAT = 90;% this is the maximum latitude (north and south) that is relevant for the analysis
% params.path_save_results = 'C:\Users\dani\Documents\My Dropbox\RBES\results';% C:\Users\Ana-Dani\Dropbox\RBES
params.path_save_results = 'C:\Users\Ana-Dani\Dropbox\RBES\results';% C:\Users\Ana-Dani\Dropbox\RBES
params.scenario_name = 'Cubesat';
params.scenario_path = ['/Scenario/' params.scenario_name '/'];% will use this later
params.headers = {'nsat_per_plane'	'nplanes'	'altitude'	'inclination'	'ltan'	'sensor_fov'	'avg_revisit_time'	'avg_revisit_time_tropics'	'avg_revisit_time_NH'	'avg_revisit_time_SH'	'avg_revisit_time_cold_regions'	'avg_revisit_time_US'};

params.sensor.type = 'Rectangular';% 'Rectangular' , 'SimpleCone' , or 'HalfPower'
params.sensor.FOV_x = 45;% in deg
params.sensor.FOV_y = 20;% in deg, only for rectangular
params.sensor.pointing = 'Fixed'; % 'Spinni

agiInit;
remMachine = stkDefaultHost;
params.conid = stkOpen(remMachine);% params structure will be use to call internal function

stkNewObj('/','Scenario',params.scenario_name);% creates scenario
stkSetTimePeriodInSec(0, params.DURATION)
call = ['SetAnimation ' params.scenario_path ' TimeStep ' num2str(params.TSTEP)];
stkExec(params.conid,call);

n = length(granularities);
results = cell(n,1);
rev_times = zeros(n,12);
for i = 1:n
    fprintf('Simulating constellation %d from %d\n',i,n);
    params.GRANULARITY = granularities(i);%
    results{i} = analyze_constellation(1, 1, 800, SSO_h_to_i(800), LTAN_to_RAAN(21.5), params.sensor, params);
    rev_times(i,:) = results{i}.avg_global;
end

plot(granularities,rev_times(:,7),'bx');