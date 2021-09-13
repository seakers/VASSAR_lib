function [sciences,costs,packs] = PACK_sensitivity_to_orbit(instruments,orbits,PLOT)
%% PACK_sensitivity_to_orbit.m
% Usage:
% instruments = {'HYSP_VIS'};
% orbits = {'SSO-400-SSO-DD','SSO-600-SSO-DD','SSO-800-SSO-DD','SSO-800-SSO-AM','SSO-800-SSO-PM'};
% [sciences,costs] = PACK_sensitivity_to_orbit(instruments,orbits)
% 

global params
nn = length(orbits);
sciences = zeros(1,nn);
costs = zeros(1,nn);
packs = zeros(1,nn);
for i = 1:length(orbits)
    orbit = get_orbit_struct_from_string(orbits{i});
    mission = create_test_mission('test',instruments,params.startdate,params.lifetime,orbit);
    [sciences(i),~,~,~,~,~,costs(i),~,packs(i)] = RBES_Evaluate_Mission(mission);
end
if PLOT
    f = figure;
    ax = axes('Parent',f);
    set(ax,'FontSize',18);
    plot(sciences,costs,'bd','MarkerSize',10,'MarkerFaceColor','b','ButtonDownFcn', {@show_orbit,orbits,sciences,costs,params});
    grid on;
    xlabel('Science','FontSize',18);
    ylabel('Lifecycle cost','FontSize',18);
    title('Effect of orbit selection on science and cost','FontSize',18);
    nombre = StringArraytoStringWithSpaces(instruments);
    nombre = regexprep(nombre,' ','_');
    print('-dmeta',[params.path_save_results 'packaging\PACK--orbit-sensitivity-' nombre]);
end
end

function show_orbit(src,eventdata,orbits,sciences,costs,params)
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [val, i] = min(abs((sciences - xmouse)/xmouse).^2+abs((costs - ymouse)/ymouse).^2);
    xpoint   = sciences(i);
    ypoint   = costs(i);
    orb = orbits{i};
    fprintf('Orb = %s, science = %f, cost = %f\n',orb,sciences(i),costs(i));
end