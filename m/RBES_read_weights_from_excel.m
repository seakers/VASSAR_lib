function [w_sh,w_obj,w_sub] = RBES_read_weights_from_excel
    global params
    load_aggregation_rules_from_excel;
    jess clear;
    RBES_Init_WithRules;
    w_sh = params.panel_weights;
    w_obj = params.obj_weights;
    w_sub = params.subobj_weights;
end