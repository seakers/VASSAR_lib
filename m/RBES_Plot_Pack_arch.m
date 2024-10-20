function RBES_Plot_Pack_arch(ax,arch)
global params
nsats = max(arch);

rec = zeros(nsats,1);
w = 0.8;
y = 0;
dx = 0.1;
w2 = 0.6;
h2 = 0.8;
dy = 0.2;
delta = (5-nsats)/(nsats+ 1);

if(isempty(ax))
    figure;
else
    axes(ax);
    cla;
end
for s = 1:nsats
    sat = find(arch == s);
    sat_instrs = params.packaging_instrument_list(sat);
    instr_names = regexprep(sat_instrs,'_',' ');
    x = delta + (1+delta)*(s-1);
    ni = length(sat);
    h = ni*1 + 2*dy;
    rec(s) = rectangle('Position',[x,y,w,h+dy],'Curvature',[0],'LineWidth',2,'LineStyle','-');        
    rec2 = zeros(nsats,1);
    y2 = 0;
    for ins = 1:ni
        rec2(ins) = rectangle('Position',[x+dx,y2+3*dy,w2,h2],'FaceColor','y');
        text(x+dx+dx,y2+3*dy+h2/2,instr_names{ins},'FontSize',8);
        y2 = y2 + 1;
    end
    
 
    
end
axis([0 5 0 7]);
axis off;
return