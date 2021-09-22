function SMAP_java_plot(stack,SAVE)
NN = stack.size;
sciences = zeros(NN,1);
costs = zeros(NN,1);
pareto_ranks = zeros(NN,1);
archs = cell(NN,1);
for i = 1:NN
    sciences(i) = stack.get(i-1).getScience();
    costs(i) = stack.get(i-1).getCost();
    pareto_ranks(i) = stack.get(i-1).getCost();
    archs{i} = stack.get(i-1).getArch();
end
% sciences = results.sciences;
% costs = results.costs;
% pareto_ranks = results.pareto_ranks;

% utilities = results.utilities;
scrsz = get(0,'ScreenSize');
f = figure('Position',[1 0 0.55*scrsz(3) 0.6*scrsz(4)]);
ax = axes('Parent',f,'FontSize',18);
pl = plot(sciences,costs,'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','b','MarkerFaceColor','b', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs,sciences,costs,pareto_ranks});
hold on;
front = paretofront([-sciences costs]);
fr = plot(sciences(front),costs(front),'Marker','d','Parent',ax,'MarkerSize', 8, 'MarkerEdgeColor','g','MarkerFaceColor','g', 'LineStyle','None', ...
    'ButtonDownFcn', {@test_plot,archs(front),sciences(front),costs(front),pareto_ranks(front)});
utopia = plot(max(sciences),min(costs),'yp','MarkerSize', 10,'MarkerFaceColor','y','Parent',ax);

% range_x = max(sciences) - min(sciences);
% range_y = max([costs;params.ref_pack_arch.cost]) - min([costs;params.ref_pack_arch.cost]);
% axis([min(sciences) - 0.1*range_x , max(sciences) + 0.1*range_x , min([costs;params.ref_pack_arch.cost]) - 0.1*range_y, max([costs;params.ref_pack_arch.cost]) + 0.1*range_y]);
grid on;
xlabel('Normalized Science');
ylabel('Lifecycle cost (FY00$M)');
legend({'Dominated Architectures','Pareto Front','Utopia point'},'Location','Best');
if SAVE
    tmp = clock();
    hour = num2str(tmp(4));
    minu = num2str(tmp(5));
    filesave = ['./results/SMAP--science-vs-cost-' date '-' hour '-' minu '.emf'];
    print('-dmeta',filesave);
end
end
function test_plot(src,eventdata,archs,sciences,costs,pareto_ranks)
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [val, i] = min(abs((sciences - xmouse)/xmouse).^2+abs((costs - ymouse)/ymouse).^2);
    arch = archs{i};
    fprintf('%s, Science = %f, Cost = %f, Pareto rank = %d\n',char(arch.toString()),sciences(i),costs(i),pareto_ranks(i)); 

end


