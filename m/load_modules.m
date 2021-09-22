function load_modules()
global params
r = global_jess_engine();
r.eval(['(bind ?mod_clp_file "' char(params.module_definition_clp) '")']);
r.eval('(batch ?mod_clp_file)');
end