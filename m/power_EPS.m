%% mass_EPS.m
function [P_BOL] = power_EPS(Pavg_payload,Ppeak_payload,frac_sunlight,worst_sun_angle,period,lifetime,~,~)
%% Parameters
Xe                          = 0.65; % efficiency from solar arrays to battery to equipment (SMAD page 415)
Xd                          = 0.85; % efficiency from solar arrays to equipment (SMAD page 415)
P0                          = 253;% in W/m2, corresponds to GaAs, see SMAD page 412,
Id                          = 0.77; % See SMAD page 412
degradation                 = 2.75/100; % Degradation of solar arrays performance in % per year, corresponds to multi-junction
% Spec_power_SA               = 25; % in W per kg see SMAD chapter 11
n                           = 0.9; % Efficiency of battery to load (SMAD page 422).
% Spec_energy_density_batt    = 40; % In Whr/kg see SMAD page 420, corresponds to Ni-H2
% LENGTH_SA                   = 1; % Max length of solar panels in m.

%% Solar arrays
Pavg_payload    = Pavg_payload./0.4; % 0.3 SMAD page 340 to take into account bus power
Ppeak_payload   = Ppeak_payload./0.4; % 0.3 SMAD page 340 to take into account bus power
period          = period*60;
Pd              = 0.8*Pavg_payload' + 0.2*Ppeak_payload';
Pe              = Pd;
Td              = period.*frac_sunlight;
Te              = period - Td;

% What we need in terms of power from the SA
Psa             = (Pe.*Te./Xe+Pd.*Td./Xd)./Td;

% What the SA technology can give
theta           = worst_sun_angle.*pi/180; % Worst case Sun angle
P_density_BOL   = abs(P0.*Id.*cos(theta));
Ld              = (1-degradation).^lifetime;
P_density_EOL   = P_density_BOL.*Ld;

% Surface required
Asa             = Psa./P_density_EOL;

% Power at BOL
P_BOL           = P_density_BOL.*Asa;



end 