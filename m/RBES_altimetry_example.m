%% RBES_altimetry_example.m
RBES_Init_Params_EOS;
params.instrument_list = {'ALT-SSALT','GGI','DORIS','TMR'};
payls = {'ALT-SSALT' 'ALT-SSALT TMR' 'ALT-SSALT DORIS' 'ALT-SSALT GGI' 'ALT-SSALT TMR GGI' 'ALT-SSALT TMR DORIS' 'ALT-SSALT GGI DORIS' 'ALT-SSALT TMR GGI DORIS'};
nsats = [1 2];
orb_types = {'SSO' 'LEO'};
orb_alts = [800 1300];
orb_incs = {'SSO' 'near-polar'};
orbit_raans = {'AM','NA'};
n = length(payls)*length(nsats)*length(orb_types);
[r,params] = RBES_Init_WithRules(params);
scores = zeros(n,1);
rms_vecs = zeros(n,8);
costs = zeros(n,1);

jess unwatch all
nn = 1;
for i1 = 1:length(payls) % payloads
    payl = payls{i1};
    
    for i2 = 1:length(nsats) % nsats
        ns = nsats(i2);
        for i3 = 1:length(orb_types) % orbits
            orb_type = orb_types{i3};
            h = orb_alts(i3);
            inc = orb_incs{i3};
            raan = orbit_raans{i3};  
            r.reset;
            for j = 1:nsats(i2) % assert as many sats as needed
                r.eval(['(assert(MANIFEST::Mission (Name Altimetry' num2str(nn) num2str(j) ') (num-of-planes# 1) (num-of-sats-per-plane# ' num2str(ns) ...
                ') (orbit-type ' orb_type ') (orbit-altitude# ' num2str(h) ') (orbit-inclination ' inc ') (orbit-RAAN ' raan ') ' ...
                '(launch-date 1999) (lifetime 8) (select-orbit no) (instruments ' payl ')))']);
            end
            
            results = RBES_Evaluate_Manifest(r,params);
            r.eval('(bind ?result (run-query* SYNERGIES::get-error-budget "3.2.1 Sea level height"))');
            r.eval('(?result next)');
            rms_vecs(nn,1) = r.eval('(?result getFloat rms-POD)').floatValue(r.getGlobalContext());
            rms_vecs(nn,2) = r.eval('(?result getFloat rms-tropo)').floatValue(r.getGlobalContext());
            rms_vecs(nn,3) = r.eval('(?result getFloat rms-iono)').floatValue(r.getGlobalContext());
            rms_vecs(nn,4) = r.eval('(?result getFloat rms-ins)').floatValue(r.getGlobalContext());
            rms_vecs(nn,5) = r.eval('(?result getFloat rms-var)').floatValue(r.getGlobalContext());
            rms_vecs(nn,6) = r.eval('(?result getFloat rms-dry)').floatValue(r.getGlobalContext());
            rms_vecs(nn,7) = r.eval('(?result getFloat rms-tide)').floatValue(r.getGlobalContext());
            rms_vecs(nn,8) = r.eval('(?result getFloat rms-total)').floatValue(r.getGlobalContext());
            scores(nn) = results.score;
            costs(nn) = results.cost;
            fprintf('Arch %d of %d done\n',nn,n);
            nn = nn + 1;
        end
    end
end 

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
