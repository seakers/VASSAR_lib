function plotUnionPopOverNFE()
%Takes the union of all trials and plots the approximate front from each
%algorithm and plots them against each other at distinct points in time


PATH = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/AIAA JAIS';

methods = {'baseline.mat';
    'aos_noFilter_noCross_x4_all.mat';
    'random_noFilter_noCross_x4_all.mat'};

nfeIntervals = [1000,1250,1500,2000];

%load refPop to show Pareto front
load(strcat(PATH,filesep,'analysis',filesep,'pop_final',filesep,'refPop.mat'));
[~,ind] = sort(objectives(:,1));
pf = objectives(ind,:);

colors = {
    [0         0.4470    0.7410]
    [0.8500    0.3250    0.0980]
    [0.9290    0.6940    0.1250]
    [0.4940    0.1840    0.5560]
    [0.4660    0.6740    0.1880]
    [0.3010    0.7450    0.9330]
    [0.6350    0.0780    0.1840]};

markers = {'o','+','s','p'};

try
    eoss_java_init();
    figure(1)
    for nfe_i=1:length(nfeIntervals)
        subplot(2,length(nfeIntervals)/2,nfe_i);
        %plot pareto front
        plot(-pf(:,1),pf(:,2),'--k')
        hold on
        for method_j = 1:length(methods)
            load(strcat(PATH,filesep,'analysis',filesep,'pop_all',filesep,methods{method_j}));
            tmp = objectives(nfe < nfeIntervals(nfe_i),:);
            
            ndPop = org.moeaframework.core.NondominatedPopulation;
            for soln_k=1:size(tmp,1)
                ndPop.add(org.moeaframework.core.Solution(tmp(soln_k,:)));
            end
            
            iter = ndPop.iterator();
            unionFront = zeros(ndPop.size(), size(objectives,2));
            n = 1;
            while iter.hasNext
                unionFront(n,:) = iter.next().getObjectives;
                n = n + 1;
            end
            scatter(-unionFront(:,1),unionFront(:,2),30,colors{method_j},markers{method_j})
        end
        hold off
        xlabel('Scientific Benefit')
        ylabel('Lifecycle cost ($FY10M)')
        title(sprintf('%d NFE', nfeIntervals(nfe_i)))
        axis([0,0.35,0,4000])
        set(gca,'FontSize',14);
%         legend('PF^*', '\epsilonMOEA','aos','all', 'random', 'location','northwest')
        legend('PF^*', '\epsilonMOEA','KDO\\AOS', 'location','northwest')
    end
catch me
    clear ndPop iter
    eoss_java_end();
    disp(me.message);
end
clear ndPop iter
eoss_java_end();