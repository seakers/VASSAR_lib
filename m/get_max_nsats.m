function mx = get_max_nsats()
r = global_jess_engine();
jess bind ?mx (get-max-nsats nil);
mx = jess_value(r.eval('?mx'));
end