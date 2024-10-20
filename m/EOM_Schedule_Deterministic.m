function EOM_out = EOM_Schedule_Deterministic(EOM_in)
%% EOM_Schedule_Deterministic.m
% This function estimates the development time of an architecture which is
% a vector of the development times of its missions. Note that this
% development times assume infinite that funding is always available.
% Time to science is calculated as the minimum development time across
% missions.
% Min total development time is calculated as the maximum development time
% across missions.
% Development time of a mission is estimated by using Monte-Carlo
% simulations. Random development times samples for each instrument and for
% the bus are taken from a lognormal distribution for which the mode is set
% by the design development time plus the expected schedule slippage which
% is a function of the TRL of the instrument/bus as given by Saleh's paper
% (TRL, schedule risk and slippage in spacecraft design).
% Discounted value has a quanta of 0.02 and a precision of +/- 1 quanta.
% This means that DV1 = x and DV2 = x +/- 0.02 are not statistically
% different.

%% Parameters
% global instr_devtime_lookup_table
TRL_BUS                     = 9; % Could change with the type of bus
IDE_BUS                     = 2; % Could change with the type of bus
DISCOUNT_RATE               = 0.10;
% OVERRUN                     = 0.08;% ESA: 8%, NASA: 14%
NSIM                        = 200;

%% Inputs
N_SAT                       = EOM_in.NSats;
I2S                         = EOM_in.Instruments2Satellites;
% S2LV                        = EOM_in.Satellites2Launchers;
TRL_INS                     = EOM_in.TRLInstruments;
IDE_INS                     = EOM_in.IDEInstruments;
% N_LV                        = EOM_in.NLaunchers;
N_INSTR                     = EOM_in.NInstruments;
cost_missions               = EOM_in.CostMissions;
weight_instruments          = EOM_in.ValueInstruments;

%% Calculate CDFs of instrument development time
unknown          = find(IDE_INS); % Indexes of instruments for which IDE unknown
IDE_INS(unknown) = 8.187*exp(-.157*TRL_INS(unknown));% This exponential is fit so that it gives a min DT of 2 years for TRL = 9 and 7 years for TRL = 1.
vec_TRL          = [TRL_INS TRL_BUS];
vec_IDE          = [IDE_INS IDE_BUS];
[x,F_x]          = CDF_InstrDevTime(vec_IDE, vec_TRL);% x = zeros(1000,N_INSTR);

%% Simulate development of each instrument and satellite

instr_dev_times     = zeros(1,N_INSTR);
sat_dev_times       = zeros(1,N_SAT);
DVs                 = zeros(1,1);
vec_cost_missions   = zeros(1,N_SAT);
u                   = 0.5;

%% Random individual instrument development times
for instr = 1:N_INSTR+1 % Contains bus too, which explains the N_INSTR + 1
    [ind,cv] = searchclosest(F_x(:,instr),u);
    instr_dev_times(instr)=x(ind);
end

%% Calculate satellite development times and cost overrun
sat_IDE = zeros(N_SAT,1);
overruns = zeros(N_SAT,1);
for sat = 1:N_SAT
    ind_instruments          = I2S(:,sat);        
    sat_IDE(sat)             = max(vec_IDE(ind_instruments));
    sat_dev_times(sat)     = max(instr_dev_times(ind_instruments));
    overruns(sat)            = 0.24.*((sat_dev_times(sat)-sat_IDE(sat))./sat_IDE(sat))+0.017; % Weigel and Hastings, 2004
    vec_cost_missions(sat) = cost_missions(sat).*(1+overruns(sat));
end

%% Update instrument development times with influence of other
%% instruments
for instr = 1:N_INSTR
    instr_dev_times(instr) = sat_dev_times(I2S(instr,:));
end

%% Compute schedule metric
delay_instruments       = instr_dev_times(1:N_INSTR) - IDE_INS;
DV                      = sum(weight_instruments.*exp(-DISCOUNT_RATE.*delay_instruments),2); % Rounds schedule metric to 0.01



%% Outputs
EOM_out                     = EOM_in;
EOM_out.MissionsIDE         = sat_IDE;
EOM_out.DevTimeMissions     = sat_dev_times;
EOM_out.DevTimeInstruments  = instr_dev_times(1:N_INSTR);
EOM_out.MeanDevTime         = weight_instruments*EOM_out.DevTimeInstruments';
EOM_out.CostMissions        = vec_cost_missions;
% EOM_out.LifecycleCost       = round(1/14*round(sum(EOM_out.CostMissions)))/(1/14); %Cost in FY00$M, quanta = $14M.
EOM_out.LifecycleCost       = sum(EOM_out.CostMissions); %Cost in FY00$M, quanta = $14M.
EOM_out.ScheduleSlippage    = sat_dev_times - sat_IDE';
EOM_out.CostOverrun         = overruns;
% EOM_out.DiscountedValue     = round(50*mean(DVs,1))/50; 
EOM_out.DiscountedValue     = DV;
EOM_out.CostBudgetSatellites(:,8) = EOM_out.CostMissions.*EOM_out.CostOverrun' ;
return
%% end of EOM_DevelopmentTime.m