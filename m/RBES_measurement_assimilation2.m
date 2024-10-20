function RBES_measurement_assimilation2
r = global_jess_engine();

r.eval('(focus ASSIMILATION2)');
r.run(10000);

r.eval('(focus ASSIMILATION)');
r.run(10000);
end