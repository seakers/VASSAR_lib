function [science,cost] = SEL_get_scores(instr,ncopies,params)
values = params.map_instrument_scores.get(instr);% values = ArrayList of size 4, where values(i) = [science,cost] for i copies of the instrument
tmp = values(ncopies);
science = tmp(1);
cost = tmp(2);
end