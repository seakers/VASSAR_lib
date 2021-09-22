%% RBES_EOS_architectures.m
RBES_Init_Params_EOS;
[r,params] = RBES_Init_WithRules(params);
jess unwatch all

% altimetry
nn = 1;
alt_arc = zeros(32,3);
for i = 1:8
    for j = 1:2
        for k = 1:2
            alt_arc(nn) = [i j k];
            nn = nn + 1;
        end
    end
end 

% radiation budget

%% Plots
scrsz = get(0,'ScreenSize');
figure1 = figure('Position',[1 0 scrsz(3) scrsz(4)]);
axes1 = axes('Parent',figure1,'FontSize',40,'FontName','Arial');
p1 = plot(costs,rms_vecs(:,8),'LineStyle','none','Marker','o','Parent',axes1,'MarkerSize',15,'MarkerFaceColor','b','MarkerEdgeColor','b');
xlabel('cost ($FY00M)','FontSize',40,'FontName','Arial');
ylabel('total rms error (cm)','FontSize',40,'FontName','Arial');
title('Rms error vs cost for different mission architectures','FontSize',40,'FontName','Arial');
grid on;
print('-dmeta','alt_rmserr_vs_cost.emf');

scrsz = get(0,'ScreenSize');
figure2 = figure('Position',[1 0 scrsz(3) scrsz(4)]);
axes2 = axes('Parent',figure2,'FontSize',40,'FontName','Arial');
p2 = plot(costs,100*scores,'Marker','o','Parent',axes2,'LineStyle','none','MarkerSize',15,'MarkerFaceColor','r','MarkerEdgeColor','r');
xlabel('cost ($FY00M)','FontSize',40,'FontName','Arial');
ylabel('Science scores','FontSize',40,'FontName','Arial');
title('Science vs cost for different mission architectures','FontSize',40,'FontName','Arial');
grid on;
print('-dmeta','alt_science_vs_cost.emf');
