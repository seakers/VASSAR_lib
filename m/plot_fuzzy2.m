function plot_fuzzy2(fz1,fz2)
    int1 = fz1.getInterv;
    int2 = fz2.getInterv;
    x = [int1.getMin int1.getMean int1.getMax 0 int2.getMin/2 0];
    y = [0 int1.getMin/2 0 int2.getMin int2.getMean int2.getMax];
    tri = [1 2 3;4 5 6];
    triplot(tri,x,y,'LineWidth',4);
    hold on;
    plot([int1.getMin int1.getMean int1.getMax],[int2.getMin int2.getMean int2.getMax],'r','LineWidth',4);
    grid on;
    xlabel([char(fz1.getParam) ' (' char(fz1.getUnit) ')'],'FontSize',20);
    ylabel([char(fz2.getParam) ' (' char(fz2.getUnit) ')'],'FontSize',20);
    set(gca,'FontSize',20);
end