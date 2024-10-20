function rms_vecs = RBES_altimetry_error_budget2(fact_id)
r = global_jess_engine();
f = r.eval(['(fact-id ' num2str(fact_id) ')']).factValue(r.getGlobalContext());
rms_vecs(1) = jess_value(f.getSlotValue('rms-system-POD#'));
rms_vecs(2) = jess_value(f.getSlotValue('rms-system-tropoH2O#'));
rms_vecs(3) = jess_value(f.getSlotValue('rms-system-ionosphere#'));
rms_vecs(4) = jess_value(f.getSlotValue('rms-system-instrument#'));
rms_vecs(5) = jess_value(f.getSlotValue('rms-variable-measurement#'));
rms_vecs(6) = jess_value(f.getSlotValue('rms-system-tropo-dry#'));
rms_vecs(7) = jess_value(f.getSlotValue('rms-system-tides#'));
rms_vecs(8) = jess_value(f.getSlotValue('rms-total#'));

fprintf('POD = %f tropo = %f iono = %f ins = %f \nvar = %f dry = %f tide = %f total = %f\n',...
    rms_vecs(1),rms_vecs(2),rms_vecs(3),rms_vecs(4),rms_vecs(5),rms_vecs(6),rms_vecs(7),rms_vecs(8));
end

