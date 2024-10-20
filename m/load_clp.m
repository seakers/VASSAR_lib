function [] = load_clp(name)
r = global_jess_engine();
r.eval(['(bind ?file ".\\clp\\' name '.clp")']);
r.eval('(batch ?file)');
end