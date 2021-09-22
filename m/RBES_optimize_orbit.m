function [opt_orbit,sc,co,umax,pack] = RBES_optimize_orbit(varargin)
% Example of usage:
% orbits = {'LEO-400-polar-NA','SSO-400-SSO-AM','SSO-400-SSO-DD','SSO-600-SSO-AM','SSO-600-SSO-DD','SSO-800-SSO-AM','SSO-800-SSO-DD'};
% 

instruments = varargin{1};
orbits = varargin{2};

if nargin>2
    rule = varargin{3};
end

if strcmp(rule,'MAX_UTILITY') && nargin>3
    weights = varargin{4};
end

[sciences,costs,packs] = PACK_sensitivity_to_orbit(instruments,orbits,0);

if strcmp(rule,'MAX_SCIENCE')
    ind1 = sciences == max(sciences);% First max science
    costs2 = costs(ind1);% costs of archs that maximize science
    sciences2 = sciences(ind1);
    orb1 = orbits(ind1);
    packs2 = packs(ind1);
    if sum(ind1)>1  
        [sorted_costs,order] = sort(costs2,'ascend');% then minimize cost
        opt_orbit = orb1{order(1)};
        co = sorted_costs(1);
        sc = sciences2(order(1));
        pack = packs2(order(1));
    else
        opt_orbit = orb1{1};
        co = costs2(1);
        sc = sciences2(1);
        pack = packs2(1);
    end
    umax = [];
elseif strcmp(rule,'MAX_UTILITY')
    sc_norm = normalize_LIB(sciences);
    co_norm = normalize_SIB(costs);
    
    u = [sc_norm' co_norm']*weights';
    
    [sorted_u,order] = sort(u,'descend');% maximize utility
    umax = sorted_u(1);
    sc = sciences(order(1));
    co = costs(order(1));
    opt_orbit = orbits{order(1)};
    pack = packs(order(1));
else
    fprintf('Second argument can only be MAX_SCIENCE or MAX_UTILITY\n');
end

end