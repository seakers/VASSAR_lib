function cost_breakdown = RBES_explain_cost(sat_name)
% sat_instrs = params.packaging_instrument_list(sat);
% mission = create_test_mission(sat_name,sat_instrs,1990,8,[]);
nsats = 1;
w = 0.8; % this is the satellite 
y = 0; % this is the satellite 
dx = 0.1;
w2 = 0.6;
h2 = 0.8;
dy = 0.2; % this is the satellite 
delta = (5-nsats)/(nsats+ 1);

figure;

r.eval(['(bind ?results (run-query* GUI::show-engineering-penalties ' sat_name '))']);
jess ?results next;
jess bind ?adcs (?results getDouble adcs);
jess bind ?mech (?results getDouble mech);
jess bind ?scan (?results getDouble sc);
jess bind ?th (?results getDouble th);
jess bind ?emc (?results getDouble emc);
jess bind ?rb (?results getDouble rb);
jess bind ?lv (?results getString lv);
jess bind ?orb (?results getString orb);
jess bind ?mass (?results getDouble mass);
jess bind ?cost (?results getDouble cost);
adcs = jess_value(r.eval('?adcs'));if(adcs==1), col_adcs = 'r'; else col_adcs = 'g';end
mech = jess_value(r.eval('?mech'));if(mech==1), col_mech = 'r'; else col_mech = 'g';end
scan = jess_value(r.eval('?scan'));if(scan==1), col_scan = 'r'; else col_scan = 'g';end
th = jess_value(r.eval('?th'));if(th==1), col_th = 'r'; else col_th = 'g';end
emc = jess_value(r.eval('?emc'));if(emc==1), col_emc = 'r'; else col_emc = 'g';end
rb = jess_value(r.eval('?rb'));if(rb==1), col_rb = 'r'; else col_rb = 'g';end
mass = jess_value(r.eval('?mass'));
lv = jess_value(r.eval('?lv'));
% lv_cost = jess_value(r.eval('(get-launch-cost (eval ?lv))'));
orbit = jess_value(r.eval('?orb'));
cost = jess_value(r.eval('?cost'));
x = delta + (1+delta)*(s-1); % this is the satellite 
ni = length(sat);
h = ni*1 + 3*dy; % this is the satellite 
rec = rectangle('Position',[x,y,w,h+3*dy],'Curvature',[0],'LineWidth',2,'LineStyle','-');  % this is the satellite      
y2 = 0;
rec2 = zeros(ni,1);
for ins = 1:ni
    rec2(ins) = rectangle('Position',[x+dx,y2+4*dy,w2,h2],'FaceColor','y');
    text(x+dx+dx,y2+4*dy+h2/2,params.packaging_instrument_list{sat(ins)},'FontSize',8);
    y2 = y2 + 1;
end
% Penalties
y2 = 0;
rectangle('Position',[x+dx,y2+dy,w2/3,h2/3],'FaceColor',col_adcs);
rectangle('Position',[x+dx,y2+2*dy,w2/3,h2/3],'FaceColor',col_mech);
rectangle('Position',[x+3*dx,y2+dy,w2/3,h2/3],'FaceColor',col_scan);
rectangle('Position',[x+3*dx,y2+2*dy,w2/3,h2/3],'FaceColor',col_th);
rectangle('Position',[x+5*dx,y2+dy,w2/3,h2/3],'FaceColor',col_emc);
rectangle('Position',[x+5*dx,y2+2*dy,w2/3,h2/3],'FaceColor',col_rb);
text(x+dx,y2+dy+h2/9,'A','FontSize',6);
text(x+dx,y2+2*dy+h2/9,'M','FontSize',6);
text(x+3*dx,y2+dy+h2/9,'S','FontSize',6);
text(x+3*dx,y2+2*dy+h2/9,'T','FontSize',6);
text(x+5*dx,y2+dy+h2/9,'E','FontSize',6);
text(x+5*dx,y2+2*dy+h2/9,'D','FontSize',6);
text(x+dx,y2+dy/2,lv,'FontSize',6);
text(x+dx,y+h+dy/2,[num2str(round(mass)) ' kg'],'FontSize',6);
text(x+dx,y+h+3*dy/2,[num2str(round(cost)) ' $M'],'FontSize',6);
text(x+dx,y+h+5*dy/2,orbit,'FontSize',6);
cost_breakdown = RBES_get_cost_breakdown(sat_name);
end