function [metric,sat_dev_times] = RBES_estimate_dev_time(arch)
global params
instrums = params.packaging_instrument_list;
N_INSTR = length(instrums);
vec_TRL = RBES_get_instrument_TRLs(instrums)';
vec_IDE = 8.187*exp(-.157*vec_TRL);% This exponential is fit so that it gives a min DT of 2 years for TRL = 9 and 7 years for TRL = 1.
[x,F_x] = CDF_InstrDevTime(vec_IDE, vec_TRL);% x = zeros(1000,N_INSTR);


instr_dev_times     = zeros(1,N_INSTR);
u=0.5;
for instr = 1:N_INSTR % Contains bus too, which explains the N_INSTR + 1
    [ind,~] = searchclosest(F_x(:,instr),u);
    instr_dev_times(instr)=x(ind);
end
N_SAT = max(arch);
sat_dev_times = zeros(N_SAT,1);
for sat = 1:N_SAT
    ind_instruments        = (arch==sat);        
    sat_dev_times(sat)     = max(instr_dev_times(ind_instruments));
end
metric = mean(sat_dev_times);
end