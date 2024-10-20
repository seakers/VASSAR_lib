function RBES_update_pack_plot(params)
db_pack = get_db_pack();
[sciences,costs,utilities,~] = get_metrics_from_db_pack(db_pack);
umin = min(utilities);
umax = max(utilities);
u1 = u_to_mag(1/4,umin,umax);
u2 = u_to_mag(1/2,umin,umax);
u3 = u_to_mag(3/4,umin,umax);



scrsz = get(0,'ScreenSize');
figure1 = figure('Position',[1 0 scrsz(3) scrsz(4)]);
ax = axes('Parent',figure1,'FontSize',14,'FontName','Arial');
hold(ax,'all');


plot(sciences,costs,'bx');

[x1,y1] = iso_utility_line(u1,params.WEIGHTS,min(sciences),max(sciences),min(costs),max(costs));
line(x1,y1,'LineStyle','--','Color',[1 0 0]);
[x2,y2] = iso_utility_line(u2,params.WEIGHTS,min(sciences),max(sciences),min(costs),max(costs));
line(x2,y2,'LineStyle','--','Color',[0 1 0]);
[x3,y3] = iso_utility_line(u3,params.WEIGHTS,min(sciences),max(sciences),min(costs),max(costs));
line(x3,y3,'LineStyle','--','Color',[0 0 1]);
l1 = ['u25=' num2str(1/100*round(100*u1))];
l2 = ['u50=' num2str(1/100*round(100*u2))];
l3 = ['u75=' num2str(1/100*round(100*u3))];

xlabel('science','FontSize',18,...
    'FontName','Arial');
ylabel('cost ($M)','FontSize',18,...
    'FontName','Arial');
title('Science vs cost for packaging architectures in DB','FontSize',18,...
    'FontName','Arial');
leg = legend('arch',l1,l2,l3);
set(leg,'Location','NorthWest');

end

function mag = u_to_mag(u,mi,ma)
% in u = magn - magn_min / magn_max - magn_min returns magn from u
mag = mi + u*(ma - mi);
end

function [x,y] = iso_utility_line(u0,weights,scmin,scmax,cmin,cmax)
% returns the two vectors [x1 x2] [y1 y2] such that the line that passess
% through (x1,y1) and (x2,y2) is the iso-utility u0
weights = weights./(sum(weights));%normalize weights
w_cost = weights(2);
usc1 = u0*(1+w_cost) - w_cost;
x1 = u_to_mag(usc1,scmin,scmax);
y1 = cmin;

auco2 = 1 - (u0*(w_cost + 1) - 1)/w_cost;
y2 = u_to_mag(auco2,cmin,cmax);
x2 = scmax;

x = [x1 x2];
y = [y1 y2];
end