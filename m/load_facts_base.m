function [] = load_facts_base(filename)
    is = java.io.FileInputStream(filename);
    j = global_jess_engine();
    j.bload(is);
    jess bind ?*matlab* ((new matlabcontrol.MatlabProxyFactory) getProxy);
end