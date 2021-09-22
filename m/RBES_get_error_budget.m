function rms_vecs = RBES_get_error_budget()
r = global_jess_engine();
r.eval('(bind ?result (run-query* SYNERGIES::get-error-budget "3.2.1 Sea level height"))');
r.eval('(?result next)');
rms_vecs = zeros(1,8);
rms_vecs(1) = r.eval('(?result getFloat rms-POD)').floatValue(r.getGlobalContext());
rms_vecs(2) = r.eval('(?result getFloat rms-tropo)').floatValue(r.getGlobalContext());
rms_vecs(3) = r.eval('(?result getFloat rms-iono)').floatValue(r.getGlobalContext());
rms_vecs(4) = r.eval('(?result getFloat rms-ins)').floatValue(r.getGlobalContext());
rms_vecs(5) = r.eval('(?result getFloat rms-var)').floatValue(r.getGlobalContext());
rms_vecs(6) = r.eval('(?result getFloat rms-dry)').floatValue(r.getGlobalContext());
rms_vecs(7) = r.eval('(?result getFloat rms-tide)').floatValue(r.getGlobalContext());
rms_vecs(8) = r.eval('(?result getFloat rms-total)').floatValue(r.getGlobalContext());
end