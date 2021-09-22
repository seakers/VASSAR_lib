function sats = break_sat(sats,ind)
nsat = length(sats);
sat = sats{ind};
upto = ceil(length(sat)/2);
sat1 = sat(1:upto);
sat2 = sat(upto+1:end);
sats{ind} = sat1;
sats{nsat+1} = sat2;
end
