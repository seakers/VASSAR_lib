function opt_orbit = RBES_Select_Orbit2
%% RBES_Select_Orbit2.m
% This function assigns an orbit by optimizing science and cost instead of
% using the orbit selection rules
%
% Daniel Selva, Mar 27 2012
global params
MAX_SIZE = 1000;
list = params.packaging_instrument_list;
r = global_jess_engine();
orbits = {'LEO-400-polar-NA','SSO-400-SSO-AM','SSO-400-SSO-DD','LEO-600-polar-NA',...
    'SSO-600-SSO-AM','SSO-600-SSO-DD','SSO-800-SSO-AM','SSO-800-SSO-DD'};
best_orbits = RBES_get_parameter('best_orbits');

facts = r.listFacts(); % iterator

while facts.hasNext()
    f = facts.next();
    if ~strcmp(f.getDeftemplate,'[deftemplate MANIFEST::Mission]')
        continue
    end
    id = f.getFactId;
    payload = jess_value(f.getSlotValue('instruments'));
    tmp = regexp(payload,'\s','split');
    instruments = tmp{1};
    indexes = sort(PACK_get_indexes({'SMAP_RAD','SMAP_MWR'},list),'ascend');
    if best_orbits.containsKey(indexes)
        opt_orbit = best_orbits.get(num2str(indexes));
    else
        [opt_orbit,~,~,~] = RBES_optimize_orbit(instruments,orbits,'MAX_UTILITY',[0.5 0.5]);
        if best_orbits.size<=MAX_SIZE
            best_orbits.put(num2str(indexes),opt_orbit);
        end
    end
    [typ,h,inc,raan] = get_orbit_params(opt_orbit);
    r.eval(['(modify ' num2str(id) ' (in-orbit "' char(opt_orbit) '")' ...
        ' (orbit-altitude# ' num2str(h) ' ) (orbit-inclination ' inc ' ) (orbit-raan ' raan ' ) (orbit-type ' typ ' ))']);
end

RBES_set_parameter('best_orbits',best_orbits);

end