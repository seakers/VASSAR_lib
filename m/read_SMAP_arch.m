function read_SMAP_arch()
[facts,values] = my_jess_query_multi('ENUMERATION::SMAP-ARCHITECTURE','payload',0);
payload = StringArraytoStringWithSpaces(jess_value(facts{1}.getSlotValue('payload')));
packaging = cell2mat(jess_value(facts{1}.getSlotValue('sat-assignments')));
np = jess_value(facts{1}.getSlotValue('num-planes'));
ns = jess_value(facts{1}.getSlotValue('num-sats-per-plane'));
h = jess_value(facts{1}.getSlotValue('orbit-altitude'));
raan = jess_value(facts{1}.getSlotValue('orbit-raan'));
inc = jess_value(facts{1}.getSlotValue('orbit-inc'));
typ = jess_value(facts{1}.getSlotValue('orbit-type'));

fprintf('Arch: of payload = %s, assign = %s\n',payload,num2str(packaging));
fprintf('Arch: %d planes, %d sats per plane, orbit %s, h = %f, inc = %s, raan=%s\n',np,ns,typ,h,inc,raan);

end