function mission = RBES_Create_Mission(arch, orbit, instrument_list,params)
mission = Mission(orbit,arch);
mission.instrument_list = instrument_list;
mission.orbit
for i = 1:length(instrument_list)
    instr = params.instrument_pool.get(instrument_list{i});

    mission.addInstrument(instr);
end
return