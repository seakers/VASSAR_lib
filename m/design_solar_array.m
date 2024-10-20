%% design_solar_array.m
function [mass_SA] = design_solar_array(Pavg_payload,Ppeak_payload,frac_sunlight,worst_sun_angle,period,lifetime)
%% Parameters
Xe                          = 0.65; % efficiency from solar arrays to battery to equipment (SMAD page 415)
Xd                          = 0.85; % efficiency from solar arrays to equipment (SMAD page 415)
P0                          = 301;% in W/m2, see SMAD page ??
Id                          = 0.77; % See SMAD page ??
degradation                 = 3.75/100; % Degradation of solar arrays performance in % per year
Spec_power_SA               = 25; % in W per kg see SMAD chapter 11

%% Solar arrays
Pavg_payload    = Pavg_payload./0.3; % SMAD page 340 to take into account bus power
Ppeak_payload   = Ppeak_payload./0.3; % SMAD page 340 to take into account bus power

Pd              = Pavg_payload';
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

% Mass of the SA
mass_SA        = P_BOL./Spec_power_SA;% 1kg per 25W at BOL (See SMAD chapter 10).
end