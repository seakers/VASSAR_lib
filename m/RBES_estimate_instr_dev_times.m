function dev_times = RBES_estimate_instr_dev_times(TRLs)
dev_times = 8.187*exp(-.157*TRLs).*(1+8.29*exp(-0.56.*TRLs));
end
