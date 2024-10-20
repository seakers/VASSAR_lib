function RBES_Show_Penalties3(sats,SAVE)
global params
nsats = length(sats);
fsz1 = 11;%14 for eos
fsz2 = 13;%18 for eos
w = 3.0; % width of satellite box (1.6 for EOS and 2,0 for Decadal on Dell laptop)
delta = w/16;% a small value

dx = delta;% x spacing between satellite boxes
w2 = w-2*dx;%width of an instrument box
h2 = 0.8;% height of an instrument box (0.4 eos/ 0.8)
w3 = w2/3;%width of a penalty box
h3 = h2/2;% height of a penalty box
dy = delta; % y space between instrument boxes
y = dy; % this is the satellite 
%     dx = (5-nsats)/(nsats+ 1);
scrsz = get(0,'ScreenSize');
figure1 = figure('Position',[1 0 scrsz(3) scrsz(4)]);
axes('Parent',figure1,'FontSize',40,'FontName','Arial');

total_mass = 0;
total_cost = 0;
a = 0;b= 0;
for s = 1:nsats
    sat = sats{s};
    sat_instrs = sat.payload;
    instr_names = regexprep(sat_instrs,'_',' ');

    adcs = sat.penalties.adcs;if(adcs==1), col_adcs = 'r'; else col_adcs = 'g';end
    mech = sat.penalties.mech;if(mech==1), col_mech = 'r'; else col_mech = 'g';end
    scan = sat.penalties.scan;if(scan==1), col_scan = 'r'; else col_scan = 'g';end
    th = sat.penalties.th;if(th==1), col_th = 'r'; else col_th = 'g';end
    emc = sat.penalties.emc;if(emc==1), col_emc = 'r'; else col_emc = 'g';end
    rb = sat.penalties.rb;if(rb==1), col_rb = 'r'; else col_rb = 'g';end
    mass = sat.mass;total_mass = total_mass + mass;
    lv = sat.lv;
%     lv_cost = sat.lv_cost;total_launch_cost = total_launch_cost + lv_cost;
%         orbit = jess_value(r.eval('?orb'));
    orbit = sat.orbit;
    cost = sat.cost;total_cost = total_cost + cost;


    x = dx + (w+dx)*(s-1); % this is the satellite 
    ni = length(sat_instrs);
    h = (ni+2)*(h2+dy)+2*dy; % this is the satellite ni*1 + 3*dy;
    rectangle('Position',[x,y,w,h],'Curvature',[0],'LineWidth',2,'LineStyle','-');  % this is the satellite      3dy
    daspect([1,1,1]);
    a = max(a,x+w+3*dx);
    b= max(b,y+h+3*dy);
    rec2 = zeros(ni,1);
    y2 = h2 + 3*dy;
    for ins = 1:ni
        rec2(ins) = rectangle('Position',[x+dx,y2,w2,h2],'FaceColor','c');
        text(x+dx+dx,y2+h2/2,instr_names{ins},'FontSize',fsz2);
        y2 = y2 + (h2+dy);
    end
%         max_y2 = y2;
%     text(x+dx,y2+dy/2,['Launcher: ' lv],'FontSize',fsz1);
%     text(x+dx,y2+dy/2+h2/2,['Dry mass: ' num2str(round(mass)) ' kg'],'FontSize',fsz1);
% %     text(x+dx,y2+dy/2+2*h2/3,['Cost: ' num2str(round(cost)) ' $M'],'FontSize',fsz1);
%     text(x+dx,y2+dy/2+h2,['Orbit: ' orbit],'FontSize',fsz1);
    text(x+dx,y2+dy/2,[lv],'FontSize',fsz1);
    text(x+dx,y2+dy/2+h2/2,[num2str(round(mass)) 'kg'],'FontSize',fsz1);
%     text(x+dx,y2+dy/2+2*h2/3,['Cost: ' num2str(round(cost)) ' $M'],'FontSize',fsz1);
    text(x+dx,y2+dy/2+h2,[orbit],'FontSize',fsz1);
    % Penalties
    y2 = dy;
%         rectangle('Position',[x+dx,y2+dy,w3,h3],'FaceColor',col_adcs);
%         rectangle('Position',[x+dx,y2+2*dy,w3,h3],'FaceColor',col_mech);
%         rectangle('Position',[x+3*dx,y2+dy,w3,h3],'FaceColor',col_scan);
%         rectangle('Position',[x+3*dx,y2+2*dy,w3,h3],'FaceColor',col_th);
%         rectangle('Position',[x+5*dx,y2+dy,w3,h3],'FaceColor',col_emc);
%         rectangle('Position',[x+5*dx,y2+2*dy,w3,h3],'FaceColor',col_rb);
    rectangle('Position',[x+dx,y2+dy,w3,h3],'FaceColor',col_adcs);
    rectangle('Position',[x+dx,y2+dy+h3,w3,h3],'FaceColor',col_mech);
    rectangle('Position',[x+dx+w3,y2+dy,w3,h3],'FaceColor',col_scan);
    rectangle('Position',[x+dx+w3,y2+dy+h3,w3,h3],'FaceColor',col_th);
    rectangle('Position',[x+dx+2*w3,y2+dy,w3,h3],'FaceColor',col_emc);
    rectangle('Position',[x+dx+2*w3,y2+dy+h3,w3,h3],'FaceColor',col_rb);
%         text(x+dx,y2+dy+h2/9,'ADC','FontSize',fsz1);
%         text(x+dx,y2+2*dy+h2/9,'MEC','FontSize',fsz1);
%         text(x+3*dx,y2+dy+h2/9,'SCA','FontSize',fsz1);
%         text(x+3*dx,y2+2*dy+h2/9,'THE','FontSize',fsz1);
%         text(x+5*dx,y2+dy+h2/9,'EMC','FontSize',fsz1);
%         text(x+5*dx,y2+2*dy+h2/9,'DAT','FontSize',fsz1);
    text(x+dx+dx/2,y2+dy+h3/2,'ADC','FontSize',fsz1);
    text(x+dx+dx/2,y2+dy+h3/2+h3,'MEC','FontSize',fsz1);
    text(x+dx+dx/2+w2/3,y2+dy+h3/2,'SCA','FontSize',fsz1);
    text(x+dx+dx/2+w2/3,y2+dy+h3/2+h3,'THE','FontSize',fsz1);
    text(x+dx+dx/2+2*w2/3,y2+dy+h3/2,'EMC','FontSize',fsz1);
    text(x+dx+dx/2+2*w2/3,y2+dy+h3/2+h3,'DAT','FontSize',fsz1);

    
    
end
%     axis([0 dx+nsats*(dx+1) 0 y+h+3*dy+dy]);
axis([0 a 0 b]);% 0 5 0 7

axis off;
if SAVE
    savepath = [params.path_save_results 'packaging\'];
    tmp = clock();
    hour = num2str(tmp(4));
    minu = num2str(tmp(5));
    filesave = [savepath 'PACK--cost-explanations-' date '-' hour '-' minu '.emf'];
    print('-dmeta',filesave);
end
end