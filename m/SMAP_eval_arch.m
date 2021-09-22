function results = SMAP_eval_arch(arch_str)
    r = global_jess_engine;
    jess reset;
    r.eval(['(assert-string "' char(arch_str) '")']);
    
    results = RBES_Evaluate_Manifest3;
end