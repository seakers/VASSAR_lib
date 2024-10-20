function trls = RBES_get_instrument_TRLs(instrums)
global params
r = global_jess_engine();


jess bind ?trls (new java.util.ArrayList);
for i = 1:length(instrums)
    r.eval(['(bind ?trl (get-instrument-trl ' instrums{i} ' ))']);
    jess ?trls add ?trl;   
end
tmp = r.eval('?trls').javaObjectValue(r.getGlobalContext());
trls = cell2mat(cell(tmp.toArray));
end