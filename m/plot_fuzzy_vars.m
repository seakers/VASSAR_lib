function [h,x,y] = plot_fuzzy_vars(fzx,fzy)
   n = length(fzx);
   x = zeros(n,1);
   y = zeros(n,1);
   errxU = zeros(n,1);
   erryU = zeros(n,1);
   errxD = zeros(n,1);
   erryD = zeros(n,1);
   for i = 1:n
       x(i) = fzx{i}.getNum_val;
%        errxD(i) = fzx{i}.getNum_val - fzx{i}.getInterv.getMin;
%        errxU(i) = fzx{i}.getInterv.getMax - fzx{i}.getNum_val;
       errxD(i) = fzx{i}.getInterv.getMin;
       errxU(i) = fzx{i}.getInterv.getMax;
       y(i) = fzy{i}.getNum_val;
       erryD(i) = fzy{i}.getInterv.getMin;
       erryU(i) = fzy{i}.getInterv.getMax;
   end
   h=ploterr(x,y,{errxD,errxU},{erryD,erryU},'r.');
   set(h(2),'Color','b'), set(h(3),'Color','b'), set(h(1),'MarkerSize',15), set(h(1),'MarkerFaceColor','r');
   xlabel([char(fzx{1}.getParam) ' (' char(fzx{1}.getUnit) ')']);
   ylabel([char(fzy{1}.getParam) ' (' char(fzy{1}.getUnit) ')']);
%    set(gca,'FontSize',18);
   grid on;
%    print('-dmeta','EOCubesats_fuzzy_scores');
%    saveas(gcf, 'EOCubesats_fuzzy_scores', 'fig');
end
