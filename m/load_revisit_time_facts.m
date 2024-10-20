function load_revisit_time_facts
%% load_revisit_time_facts.m
global params
r = global_jess_engine();

%% Walker constellation revisit times
[num,txt,~]= xlsread(params.mission_analysis_database_xls,'Walker');

% read headers
headers = txt(1,:);
NPLANE = strcmp(headers,'nplanes');
NSAT = strcmp(headers,'nsat_per_plane');
ALT = strcmp(headers,'altitude');
INC = strcmp(headers,'inclination');
LTAN = strcmp(headers,'ltan');
FOV = strcmp(headers,'sensor_fov');
TGLOB = strcmp(headers,'avg_revisit_time');
TTROP = strcmp(headers,'avg_revisit_time_tropics');
TNH = strcmp(headers,'avg_revisit_time_NH');
TSH = strcmp(headers,'avg_revisit_time_SH');
TCOLD = strcmp(headers,'avg_revisit_time_cold_regions');
TUS = strcmp(headers,'avg_revisit_time_US');

% construct deffacts
call = '(deffacts Walker-revisit-time-facts "Walker revisit time facts" ';
for i = 1:size(num)
    nsats_per_plane = num(i,1);
    nplanes = num(i,NPLANE);
    altitude = num(i,ALT);
    inclination = num(i,INC);
    if inclination == 12345
        inclination = 'SSO';
    elseif inclination == 90
        inclination = 'polar';
    else
        inclination = num2str(inclination);
    end
    
    if nsats_per_plane == 1 && nplanes == 1
        arch = 'single-sat';
    else
        arch = 'constellation';
    end
    fov = num(i,FOV);
    ltan = num(i,LTAN);
    if ltan==6
        ltan='DD';
    elseif ltan==13.5
        ltan='PM';
    elseif ltan==22.5
        ltan='AM';
    end
    avg_revisit_time_global = num(i,TGLOB);
    avg_revisit_time_tropics = num(i,TTROP);
    avg_revisit_time_NH = num(i,TNH);
    avg_revisit_time_SH = num(i,TSH);
    avg_revisit_time_cold = num(i,TCOLD);
    avg_revisit_time_US = num(i,TUS);
    call = [call ' (DATABASE::Revisit-time-of (mission-architecture ' arch ' ) ' ...
        '(num-of-planes# ' num2str(nplanes) ' ) ' ...
        '(num-of-sats-per-plane# ' num2str(nsats_per_plane) ' ) ' ...
        '(orbit-altitude# ' num2str(altitude) ' ) ' ...
        '(orbit-inclination ' inclination ' ) ' ...
        '(orbit-raan ' ltan ' ) ' ...
        '(instrument-field-of-view# ' num2str(fov) ' ) ' ...
        '(avg-revisit-time-global# ' num2str(avg_revisit_time_global) ' ) ' ...
        '(avg-revisit-time-tropics# ' num2str(avg_revisit_time_tropics) ' ) ' ...
        '(avg-revisit-time-northern-hemisphere# ' num2str(avg_revisit_time_NH) ' ) ' ...
        '(avg-revisit-time-southern-hemisphere# ' num2str(avg_revisit_time_SH) ' ) ' ...
        '(avg-revisit-time-cold-regions# ' num2str(avg_revisit_time_cold) ' ) ' ...
        '(avg-revisit-time-US# ' num2str(avg_revisit_time_US) ' ) ' ...
    ') '];
    
end
call = [call ')'];
r.eval(call);

%% Orbit parameters for power budget
[~,~,raw]= xlsread(params.mission_analysis_database_xls,'Power');
call = '(deffacts orbit-parameter-for-power-design-facts "Orbit parameters for EPS design" ';
for i = 2:size(raw,1)
    orb_name = raw{i,1};
    type = raw{i,2};
    altitude = raw{i,3};
    inclination = raw{i,4};
    if ~ischar(inclination) 
        inclination = num2str(inclination); 
    end
    raan = raw{i,5};
    frac = raw{i,6};
    period = raw{i,7};
    sun_angle = raw{i,8};
    max_eclipse = raw{i,9};

    call = [call ' (DATABASE::Orbit (id "' orb_name '" ) ' ...
        '(type ' num2str(type) ' ) ' ...
        '(inclination ' char(inclination) ' ) ' ...
        '(altitude# ' num2str(altitude) ' ) ' ...
        '(RAAN# ' num2str(raan) ' ) ' ...
        '(fraction-of-sunlight# ' num2str(frac) ' ) ' ...
        '(period# ' num2str(period) ' ) ' ...
        '(worst-sun-angle# ' num2str(sun_angle) ' ) ' ...
        '(max-eclipse-time# ' num2str(max_eclipse) ' ) ' ...
        ') '];
    
end
call = [call ')'];
r.eval(call);

%% Orbit parametes for NPOESS (700km SSO orbits)
[num,~,~]= xlsread(params.mission_analysis_database_xls,'NPOESS');
jess defglobal ?*revisit-times* = 0;
jess bind ?*revisit-times* (bag create my-bag1);

for i = 1:size(num,1)
    r.eval(['(bag set ?*revisit-times* (str-cat ' num2str(num(i,1)) '-' num2str(num(i,2)) ') ' num2str(num(i,3)) ')']);
end
return