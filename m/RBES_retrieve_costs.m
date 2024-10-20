function [total_cost,nsat] = RBES_retrieve_costs
% global params
r = global_jess_engine();
% Retrieve mission costs
facts = r.listFacts();
total_cost = 0;
nsat = 0;
while facts.hasNext()
     f = facts.next();
    if ~strcmp(f.getDeftemplate,'[deftemplate MANIFEST::Mission]')
        continue
    else
        total_cost = total_cost + f.getSlotValue('lifecycle-cost#').floatValue(r.getGlobalContext());
        nsat = nsat + f.getSlotValue('num-of-sats-per-plane#').floatValue(r.getGlobalContext())*f.getSlotValue('num-of-planes#').floatValue(r.getGlobalContext());
    end
end
clear facts f; 
end
    