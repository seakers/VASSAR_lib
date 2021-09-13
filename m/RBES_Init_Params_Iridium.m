%% RBES_Init_Params_Iridium.m
function RBES_Init_Params_Iridium(varargin)
global params
params.startdate    = 2010;
params.enddate      = 2025;
params.lifetime     = 6;
params.missions_to_be_considered = 'NASA only, no Decadal';
if nargin > 0
    RBES_Init_params_common(varargin{1});
    mode = varargin{1};
else

    RBES_Init_params_common();
end

%% Parameteres to control execution
params.ASSIMILATION = 0;% not needed for EOS and Decadal, only Iridium (not really true because if 2 measurements 
                        % are cross-registered and are of same parameter,
                        % should really assimilate them and thus improve
                        % revisit time and temporal resolution 
params.EXPLANATION = 0;% for GUI
params.ESTIMATE_SCIENCE = 1;
params.ESTIMATE_COST = 1;
params.SYNERGIES = 1;
params.LOAD_RULES = 0;% 1 means to load them at each submodule instead of all at the beginning, 0 otherwise
params.CROSS_REGISTER = 1;
params.USE_LOOKUP_TABLES = 0;
params.MODE = mode;
params.TEST = 0;
params.CASE_STUDY = 'IRIDIUM';
params.WATCH_ONLY = [];
if strcmp(mode,'SCHEDULING')
    params.DATA_CONTINUITY = 1;
else
    params.DATA_CONTINUITY = 0;
end
params.BUS = 'DEDICATED';% STANDARD OR DEDICATED

%% Paths for specific xls files 
params.requirement_rules_xls            = '.\xls\Decadal Objective Rule Definition.xlsx';
params.aggregation_rules_xls            = '.\xls\Decadal Objective Rule Definition.xlsx';
params.capability_rules_xls             = '.\xls\Iridium Instrument Capability Definition.xlsx';
params.optimization_xls                 = '.\xls\Iridium Case Study Parameters.xlsx';

%% Pool of instruments to be considered
% params.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY','SPECTROM','MICROMAS','ALL_SYSTEM'};
% params.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY','SPECTROM','MICROMAS'};
% params.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY','SPECTROM'};
% params.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY','SPECTROM','MICROMAS','REFLECTOM'};
params.instrument_list = {'BIOMASS','LORENTZ_ERB','CTECS','GRAVITY','SPECTROM','MICROMAS','REFLECTOM','MICROMAS-ADV','DORIS'};

get_mask_from_instruments({'hola','si'},params.instrument_list);

% Payloads (i.e. instrument sets) to be assigned to spacecraft
params.payload_list{1}.instruments = {'BIOMASS'};
params.payload_list{2}.instruments = {'LORENTZ_ERB'};
params.payload_list{3}.instruments = {'CTECS'};
params.payload_list{4}.instruments = {'GRAVITY'};
params.payload_list{5}.instruments = {'SPECTROM'};
params.payload_list{6}.instruments = {'MICROMAS'};
params.payload_list{7}.instruments = {'CTECS','GRAVITY'};
params.payload_list{8}.instruments = {'CTECS','GRAVITY','BIOMASS','LORENTZ_ERB','SPECTROM'};
params.payload_list{9}.instruments = {'ALL_SYSTEM'};
 
params.payload_list{1}.name = {'BIOMASS'};
params.payload_list{2}.name = {'LORENTZ_ERB'};
params.payload_list{3}.name = {'CTECS'};
params.payload_list{4}.name = {'GRAVITY'};
params.payload_list{5}.name = {'SPECTROM'};
params.payload_list{6}.name = {'MICROMAS'};
params.payload_list{7}.name = {'CTECS+GRAV'};
params.payload_list{8}.name = {'ALL_BUT_MICROMAS'};
params.payload_list{9}.name = {'ALL_SYSTEM'};

%% Instrument selection
params.ref_sel_arch.arch = [1 1 1 1 1 0 0 0 0];


%% Iridium specific parameters
params.satellite_names = 'Iridium';
params.Iridium_altitude = 780;
params.Iridium_inclination = 86.4;
params.IridiumSatelliteParameters = java.util.HashMap;
for i = 1:6
    raan = pi/6*(i-1);
    for j = 1:11
        ano = 2*pi*(j-1)/11;
        id = 11*(i-1) + j;
        tmp = java.util.ArrayList;
        tmp.add(raan);
        tmp.add(ano);
        launchdate = 2015 + 0.5*i;% launch by plane, every 6 months, 2015.5-2018
        tmp.add(launchdate);
        params.IridiumSatelliteParameters.put(id,tmp);
    end
end

%% Watch
params.WATCH = 0;
params.TALK = 0;
params.MEMORY_SAVE = 0;

%% Results
params.path_save_results = '.\results\Iridium results\';
end