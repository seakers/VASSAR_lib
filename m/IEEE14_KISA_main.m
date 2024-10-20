%% IEEE14_KISA_main.m
import rbsa.eoss.*;
import rbsa.eoss.local.*;
import java.io.*;
global params
% params = Params('C:\\Users\\Ana-Dani\\Dropbox\\RBES SMAP for IEEEAero14','CRISP-ATTRIBUTES','test','normal','');
% params = Params('C:\\Users\\dani\\My Documents\\My Dropbox\\RBES SMAP for IEEEAero14','CRISP-ATTRIBUTES','test','normal','');%C:\\Users\\Ana-Dani\\Dropbox\\EOCubesats\\RBES_Cubesats7" OR C:\\Users\\dani\\My Documents\\My Dropbox\\EOCubesats\\RBES_Cubesats7
% params = Params('C:\Users\DS925\Dropbox\Nozomi - Dani\RBES SMAP for IEEEAero14','CRISP-ATTRIBUTES','test','normal','');%C:\\Users\\Ana-Dani\\Dropbox\\EOCubesats\\RBES_Cubesats7" OR C:\\Users\\dani\\My Documents\\My Dropbox\\EOCubesats\\RBES_Cubesats7
params = Params('C:\Users\Nozomi\Dropbox\Nozomi - Dani\RBES SMAP for IEEEAero14','CRISP-ATTRIBUTES','test','normal','');
%% Get results
% filenames = {'perfs_1_2013-10-10--22-53-59.rs','perfs_2_2013-10-10--22-53-38.rs','perfs_3_2013-10-10--22-53-17.rs','perfs_4_2013-10-10--22-52-57.rs','perfs_5_2013-10-10--22-52-32.rs','perfs_6_2013-10-10--22-51-55.rs'};
% filenames = {'perfs_254_2013-11-15--21-33-56.rs';'perfs_2_2013-11-15--22-34-52.rs';'perfs_1_2013-11-16--00-37-52.rs';};
% filenames = {'perfs_514_2013-11-15--18-25-59.rs';'perfs_2_2013-11-15--08-56-49.rs';'perfs_1_2013-11-15--09-15-15.rs';};
filenames = {'perfs_2_2014-01-27--17-28-24.rs';};

basic_heuristics = {'mutation1bit'};
KI_heuristics = {'randomSearch','crossover1point','improveOrbit','removeInterf','addSynergy','removeSuperfluous','addRandomToSmallSat','removeRandomFromLoadedSat','bestNeighbor','askUserToImprove'};
n = length(KI_heuristics);
% look_at = 1:2^n-1;
% look_at = {[0 1 1 1 1 1 1 1 0],[0 1 0 0 0 0 0 0 0],[1 0 0 0 0 0 0 0 0]};
dec_look_at = [2];%get from Java Main
look_at = arrayfun(@(x)de2bi(x,n),dec_look_at,'UniformOutput',false);
NIT = 3;% 3 2
MAXGEN = 10;% 5 5
% root = 'perfs2_';
N = length(look_at);
% N = 6;
results = cell(N,1);
labels = cell(N,1);
avg_pareto_distances = zeros(NIT,N);
sciences = zeros(NIT,N);
costs = zeros(NIT,N);
hist_avg_pareto_distances = zeros(N,NIT,MAXGEN);
hist_costs = zeros(N,NIT,MAXGEN);
hist_sciences = zeros(N,NIT,MAXGEN);


for i = 1:N
%     bin = de2bi(2^(i-1),n);
    bin = look_at{i};
    results{i} = SMAP_load_java_perf_results([char(params.path_save_results) '\\' filenames{i}]);
    avg_pareto_distances(:,i) = results{i}.avg_pareto_distances';
    sciences(:,i) = results{i}.cheapest_max_benefit_archs_sciences';
    costs(:,i) = results{i}.cheapest_max_benefit_archs_costs';
    hist_avg_pareto_distances(i,:,:) = cell2mat(results{i}.histories_pareto_distances);
    hist_costs(i,:,:) = results{i}.histories_costs;
    hist_sciences(i,:,:) = results{i}.histories_sciences;
    str = '';
    for j = 1:n
        if bin(j) == 1
            str = [str '+' KI_heuristics{j}];
        end
    end
    labels{i} = str(1:min(length(str),30));
    
    

end

%% Quality of final solutions plots and statistical significance tests
fontSize = 18;
rotation = 0;
labels = {'cross-over'};
% labels = {'human-input','domain-independent','random-search'};

% last population
scrsz = get(0,'ScreenSize');
figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes('Parent',gcf,'FontSize',fontSize);
color_markers = {'bd','rd','kd'};
for i = 1:N
    xx = arrayfun(@double,results{i}.last_results.benefits);
    yy = arrayfun(@double,results{i}.last_results.costs);
    plot(gca,xx,yy,color_markers{i});
    hold on;
end
xlabel('Science');
ylabel('Cost');
legend(labels);
grid on;
print('-dpng',['./results/last_pareto_fronts.png']);
close;

% avg pareto distance
scrsz = get(0,'ScreenSize');
figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes('Parent',gcf,'FontSize',fontSize);
boxplot(gca,avg_pareto_distances,labels);

text_h = findobj(gca, 'Type', 'text');

for cnt = 1:length(text_h)
    set(text_h(cnt), 'FontSize', fontSize-2, 'Rotation', rotation, 'String', labels{length(labels)-cnt+1},'VerticalAlignment', 'cap');
end
sq= 0.4;
left = 0.04;
right = 1;
bottom = sq;
top = 1-sq;
% set(gca, 'OuterPosition', [left bottom right top])
    

ylabel('Avg Pareto Distance');
grid on;
print('-dpng','./results/avg_pareto_distances.png');
close;
p1 = anova1(avg_pareto_distances);
fprintf('Anova test on avg pareto distance: %.3f\n',p1);
close;

% cheapest max science -> science
figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes('Parent',gcf,'FontSize',fontSize);
boxplot(gca,sciences,labels);




ylabel('Max science');
grid on;
print('-dpng','./results/sciences.png');
close;
p2 = anova1(sciences);
fprintf('Anova test on sciences: %.3f\n',p2);
close;

% cheapest max science -> cost
figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes('Parent',gcf,'FontSize',fontSize);
boxplot(gca,costs,labels);

text_h = findobj(gca, 'Type', 'text');
for cnt = 1:length(text_h)
    set(text_h(cnt), 'FontSize', fontSize-2, 'Rotation', rotation, 'String', labels{length(labels)-cnt+1},'VerticalAlignment', 'cap');
end
sq= 0.4;
left = 0.04;
right = 1;
bottom = sq;
top = 1-sq;
% set(gca, 'OuterPosition', [left bottom right top])

ylabel('Min cost for max science ($M)');
grid on;
print('-dpng','./results/costs.png');
close;
p3 = anova1(costs);
fprintf('Anova test on costs: %.3f\n',p3);
close;

%% Speed of convergence plots and statistical significance tests

figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes('Parent',gcf,'FontSize',fontSize);
plot(squeeze(mean(hist_avg_pareto_distances,2))','LineWidth',3);
grid on;
xlabel('Generation#');
ylabel('Avg pareto distance');
legend(labels,'Outside');
print('-dpng','./results/hist_distances.png');
close;

figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes('Parent',gcf,'FontSize',fontSize);
plot(squeeze(mean(hist_sciences,2))','LineWidth',3);
grid on;
xlabel('Generation#');
ylabel('Max science');
legend(labels,'Outside');
print('-dpng','./results/hist_sciences.png');
close;

figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes('Parent',gcf,'FontSize',fontSize);
plot(squeeze(mean(hist_costs,2))','LineWidth',3);
grid on;
xlabel('Generation#');
ylabel('Cost of max science arch');
legend(labels,'Outside');
print('-dpng','./results/hist_costs.png');
close;