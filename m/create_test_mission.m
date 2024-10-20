function mission = create_test_mission(varargin)
% mission_name,instrument_list,launchdate,lifetime,orbit,

if nargin > 0, mission_name = varargin{1};end
if nargin > 1, instrument_list = varargin{2};end
if nargin > 2, launchdate = varargin{3};end
if nargin > 3, lifetime = varargin{4};end
if nargin > 4, orbit = varargin{5};end
if nargin > 5, partnership = varargin{6};else partnership = [];end


mission.name = mission_name;
if ~isempty(orbit)
    mission.orbit.altitude = orbit.altitude;
    mission.orbit.type = orbit.type;
    mission.orbit.raan = orbit.raan;
    mission.orbit.inclination = orbit.i;
    mission.orbit.e = orbit.e;
    mission.orbit.nplanes = orbit.nplanes;
    mission.orbit.nsats_per_plane = orbit.nsatsperplane;
    if mission.orbit.nplanes*mission.orbit.nsats_per_plane>1
        mission.architecture = 'constellation';
    else
        mission.architecture = 'single-sat';
    end
else
    mission.orbit = [];
    mission.architecture = 'single-sat';
    mission.orbit.nplanes = 1;
    mission.orbit.nsats_per_plane = 1;
end

% mission.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY'};
mission.instrument_list = instrument_list;
% mission.architecture = 'constellation';
mission.launch_date = launchdate;
mission.lifetime = lifetime;
mission.partnership  = partnership;
end

