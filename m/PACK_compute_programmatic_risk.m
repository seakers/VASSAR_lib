function risk = PACK_compute_programmatic_risk(arch)
global params
instrums = params.packaging_instrument_list;
all_trls = RBES_get_instrument_TRLs(instrums);
sats = PACK_arch2sats(arch);
nsat = length(sats);
diff_trls = zeros(nsat,1);
diff_trls2 = zeros(nsat,1);

for i = 1:nsat
    trls_sat = all_trls(sats{i});
    diff_trls(i) = max(trls_sat) - min(trls_sat);
    diff_trls2(i) = mean(trls_sat) - min(trls_sat);
end

% risk = max(diff_trls);
risk = mean(diff_trls2);

end