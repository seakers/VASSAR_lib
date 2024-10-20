function cost_breakdown = RBES_Show_Penalties2(varargin)
global params
% nsats = max(arch);
arch = varargin{1};
if nargin >1
    orbits = varargin{2};
else
    fprintf('Orbits required\n');
end

if nargin >2
    ax = varargin{2};
else
    ax = [];
end

PLOT = 1;
r = global_jess_engine();
call = ['(defquery GUI::show-engineering-penalties ' ...
    '(declare (variables ?name)) ' ...
    '(MANIFEST::Mission (Name ?name) (ADCS-penalty ?adcs) (datarate-penalty ?rb) ' ...
        '(EMC-penalty ?emc) (mechanisms-penalty ?mech) (scanning-penalty ?sc) ' ...
       ' (thermal-penalty ?th) (in-orbit ?orb) (launch-vehicle ?lv) ' ...
       ' (mission-cost# ?cost) (satellite-mass# ?mass)) ' ...
     ' )' ];
r.eval(call);
r.eval('(focus GUI)');
r.run;

if PLOT
    
    nsats = max(arch);
    cost_breakdown = zeros(nsats,7);
    rec = zeros(nsats,1);
    w = 1.4; % this is the satellite 1.2
    y = 0; % this is the satellite 
    dx = 0.1;
    w2 = 1.2;%0.8
    h2 = 0.6;% 0.8
    dy = 0.2; % this is the satellite 
%     delta = (5-nsats)/(nsats+ 1);
    delta = 0.1;

    if(isempty(ax))
        scrsz = get(0,'ScreenSize');
        figure1 = figure('Position',[1 0 scrsz(3) scrsz(4)]);
        ax = axes('Parent',figure1,'FontSize',40,'FontName','Arial');
 
    else
        axes(ax);
        cla;
    end
    total_mass = 0;
    total_cost = 0;
    total_launch_cost = 0;
    a = 0;b= 0;
    for s = 1:nsats
        sat = find(arch==s);
        sat_instrs = params.packaging_instrument_list(sat);
        instr_names = regexprep(sat_instrs,'_',' ');
        sat_name = [char(params.satellite_names)  num2str(s)];
        mission = create_test_mission(sat_name,sat_instrs,params.startdate,params.lifetime,get_orbit_struct_from_string(orbits{s}));
        [score_vec,panel_scores_mat,~,subobjective_scores,~,~,cost_vec] = RBES_Evaluate_Mission(mission);
        
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
        mass = jess_value(r.eval('?mass'));total_mass = total_mass + mass;
        lv = jess_value(r.eval('?lv'));
        lv_cost = jess_value(r.eval('(get-launch-cost (eval ?lv))'));total_launch_cost = total_launch_cost + lv_cost;
%         orbit = jess_value(r.eval('?orb'));
        orbit = orbits{s};
        cost = jess_value(r.eval('?cost'));total_cost = total_cost + cost;
        
        
        x = delta + (w+delta)*(s-1); % this is the satellite 
        ni = length(sat);
        h = ni*(h2+dy) + 3*dy; % this is the satellite ni*1 + 3*dy;
        rec(s) = rectangle('Position',[x,y,w,h+3*dy],'Curvature',[0],'LineWidth',2,'LineStyle','-');  % this is the satellite      3dy
        daspect([1,1,1]);
        a = max(a,x+w+3*dx);
        b= max(b,y+h+3*dy+dy);
        rec2 = zeros(nsats,1);
        y2 = 0;
        for ins = 1:ni
            rec2(ins) = rectangle('Position',[x+dx,y2+4*dy,w2,h2],'FaceColor','c');
            text(x+dx+dx,y2+4*dy+h2/2,instr_names{ins},'FontSize',16);
            y2 = y2 + (h2+dy);
        end
%         max_y2 = y2;
        % Penalties
        y2 = 0;
%         rectangle('Position',[x+dx,y2+dy,w2/3,h2/3],'FaceColor',col_adcs);
%         rectangle('Position',[x+dx,y2+2*dy,w2/3,h2/3],'FaceColor',col_mech);
%         rectangle('Position',[x+3*dx,y2+dy,w2/3,h2/3],'FaceColor',col_scan);
%         rectangle('Position',[x+3*dx,y2+2*dy,w2/3,h2/3],'FaceColor',col_th);
%         rectangle('Position',[x+5*dx,y2+dy,w2/3,h2/3],'FaceColor',col_emc);
%         rectangle('Position',[x+5*dx,y2+2*dy,w2/3,h2/3],'FaceColor',col_rb);
        rectangle('Position',[x+dx,y2+dy,w2/3,h2/3],'FaceColor',col_adcs);
        rectangle('Position',[x+dx,y2+dy+h2/3,w2/3,h2/3],'FaceColor',col_mech);
        rectangle('Position',[x+dx+w2/3,y2+dy,w2/3,h2/3],'FaceColor',col_scan);
        rectangle('Position',[x+dx+w2/3,y2+dy+h2/3,w2/3,h2/3],'FaceColor',col_th);
        rectangle('Position',[x+dx+2*w2/3,y2+dy,w2/3,h2/3],'FaceColor',col_emc);
        rectangle('Position',[x+dx+2*w2/3,y2+dy+h2/3,w2/3,h2/3],'FaceColor',col_rb);
%         text(x+dx,y2+dy+h2/9,'ADC','FontSize',12);
%         text(x+dx,y2+2*dy+h2/9,'MEC','FontSize',12);
%         text(x+3*dx,y2+dy+h2/9,'SCA','FontSize',12);
%         text(x+3*dx,y2+2*dy+h2/9,'THE','FontSize',12);
%         text(x+5*dx,y2+dy+h2/9,'EMC','FontSize',12);
%         text(x+5*dx,y2+2*dy+h2/9,'DAT','FontSize',12);
        text(x+dx+dx,y2+dy+h2/6,'ADC','FontSize',12);
        text(x+dx+dx,y2+dy+h2/3+h2/6,'MEC','FontSize',12);
        text(x+dx+dx+w2/3,y2+dy+h2/6,'SCA','FontSize',12);
        text(x+dx+dx+w2/3,y2+dy+h2/3+h2/6,'THE','FontSize',12);
        text(x+dx+dx+2*w2/3,y2+dy+h2/6,'EMC','FontSize',12);
        text(x+dx+dx+2*w2/3,y2+dy+h2/3+h2/6,'DAT','FontSize',12);
        
        text(x+dx,y2+dy/2,lv,'FontSize',12);
        text(x+dx,y+h+dy/2,[num2str(round(mass)) ' kg'],'FontSize',12);
        text(x+dx,y+h+3*dy/2,[num2str(round(cost)) ' $M'],'FontSize',12);
        text(x+dx,y+h+5*dy/2,orbit,'FontSize',12);
        cost_breakdown(s,:) = RBES_get_cost_breakdown(sat_name);
    end
%     axis([0 delta+nsats*(delta+1) 0 y+h+3*dy+dy]);
    axis([0 a 0 b]);% 0 5 0 7

    axis off;
    fprintf('Total mass = %f, total cost = %f, total launch cost = %f\n',total_mass,total_cost,total_launch_cost);
    savepath = [params.path_save_results 'packaging\'];
    tmp = clock();
    hour = num2str(tmp(4));
    minu = num2str(tmp(5));
    filesave = [savepath 'PACK--cost-explanations-' date '-' hour '-' minu '.emf'];
    print('-dmeta',filesave);
end
end