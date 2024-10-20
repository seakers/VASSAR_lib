function best_orbits = RBES_Init_best_orbits(missions)
% global params
list = RBES_get_parameter('packaging_instrument_list');

orbits = {'LEO-400-polar-NA','SSO-400-SSO-AM','SSO-400-SSO-DD',...
    'LEO-600-polar-NA','SSO-600-SSO-AM','SSO-600-SSO-DD','SSO-800-SSO-AM','SSO-800-SSO-DD'};

best_orbits = java.util.HashMap;
for i = 1:length(missions)
    payload = StringArrayWithSpacestoStringArray(missions{i});
    [opt_orbit,~,~,~] = RBES_optimize_orbit(payload,orbits,'MAX_UTILITY',[0.5 0.5]);
    fprintf('Best orbit of %s if %s\n',missions{i},opt_orbit);
    [indexes,~] = sort(PACK_get_indexes(payload,list),'ascend');
    best_orbits.put(num2str(indexes),opt_orbit);
end
end