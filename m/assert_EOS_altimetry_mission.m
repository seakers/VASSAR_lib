function [r,params] = assert_EOS_altimetry_mission(r,params,arc)
%% arc = [payl,nsat,orbit]


altimetry_payloads = {'ALT-SSALT' 'ALT-SSALT TMR' 'ALT-SSALT DORIS' 'ALT-SSALT GGI' 'ALT-SSALT TMR GGI' 'ALT-SSALT TMR DORIS' 'ALT-SSALT GGI DORIS' 'ALT-SSALT TMR GGI DORIS'};
altimetry_nsats = [1 2];
altimetry_orb_types = {'SSO' 'LEO'};
altimetry_orb_alts = [800 1300];
altimetry_orb_incs = {'SSO' 'near-polar'};
altimetry_orbit_raans = {'AM','NA'};

i_payl = arc(1);
i_nsat = arc(2);
i_orb = arc(3);

payl = altimetry_payloads{i_payl};
ns = altimetry_nsats(i_nsat);
orb_type = altimetry_orb_types{i_orb};
h = altimetry_orb_alts(i3);
inc = altimetry_orb_incs{i3};
raan = altimetry_orbit_raans{i3}; 

for j = 1:nsats(i2) % assert as many sats as needed
    r.eval(['(assert(MANIFEST::Mission (Name Altimetry' num2str(i_payl) num2str(i_nsat) num2str(i_orb) num2str(j) ') (num-of-planes# 1) (num-of-sats-per-plane# ' num2str(ns) ...
    ') (orbit-type ' orb_type ') (orbit-altitude# ' num2str(h) ') (orbit-inclination ' inc ') (orbit-RAAN ' raan ') ' ...
    '(launch-date 1999) (lifetime 8) (select-orbit no) (instruments ' payl ')))']);
end
end
