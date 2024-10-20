function [] = save_facts_base(filename)
    os = java.io.FileOutputStream(filename);
    j = global_jess_engine();
    jess bind ?*matlab* 0;
    j.bsave(os);
end