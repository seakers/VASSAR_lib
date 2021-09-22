function [fact] = fact_id(id)
% FACT_ID, id: integer, returns jess.Fact
    fid = jess(['fact-id' id]);
    j = global_jess_engine();
    fact = fid.factValue(j.getGlobalContext());
end