function plotRandPopOverNFE()
%Takes the a random trials and plots the approximate front from an
%algorithm and plots them against each other at distinct points in time


PATH = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/ASC Paper';

methods = {'new_baseline_eps_001_1';
    'new_emoea_operator_aos_checkChange_allSat_1Inst_eps_001_1';
    'new_emoea_constraint_dnf_pop_archive_eps_001_1';
    'new_emoea_constraint_ach_pop_archive_eps_001_1'};

nfeIntervals = [500,1000,2000,5000];

%load refPop to show Pareto front
load(strcat(PATH,filesep,'analysis',filesep,'pop_final',filesep,'refPop.mat'));
[~,ind] = sort(objectives(:,1));
pf = objectives(ind,:);

colors = {
    [0         0.4470    0.7410]
    [0.8500    0.3250    0.0980]
%     [0.9290    0.6940    0.1250]
    [0.4940    0.1840    0.5560]
    [0.4660    0.6740    0.1880]
    [0.3010    0.7450    0.9330]
    [0.6350    0.0780    0.1840]};

markers = {'o','+','s','p'};

try
    eoss_java_init();
    figure(1)
    
    %plot pareto fronts in each subplot
    for nfe_i=1:length(nfeIntervals)
        subplot(2,length(nfeIntervals)/2,nfe_i);
        plot(-pf(:,1),pf(:,2),'--k')
        hold on
    end
    
    for method_j = 1:length(methods)
        %select random trial
        files = dir(strcat(PATH,filesep,methods{method_j},filesep,'*all.pop'));
        ind = randi(length(files),1);
        file = java.io.File(strcat(files(ind).folder,filesep,files(ind).name));
        allPop = org.moeaframework.core.PopulationIO.read(file);
        
        for nfe_i=1:length(nfeIntervals)
            %find nondominated solutions that are within NFE
            ndPop = org.moeaframework.core.NondominatedPopulation;
            iter = allPop.iterator;
            while(iter.hasNext())
                soln = iter.next;
                if(soln.getAttribute('NFE') < nfeIntervals(nfe_i))
                    ndPop.add(soln);
                end
            end
            
            iter = ndPop.iterator();
            unionFront = zeros(ndPop.size(), size(objectives,2));
            n = 1;
            while iter.hasNext
                unionFront(n,:) = iter.next().getObjectives;
                n = n + 1;
            end
            
            subplot(2,length(nfeIntervals)/2,nfe_i);
            scatter(-unionFront(:,1),unionFront(:,2),30,colors{method_j},markers{method_j})
        end
    end
    
    %set axis and labels
    for nfe_i=1:length(nfeIntervals) 
        subplot(2,length(nfeIntervals)/2,nfe_i);
        hold off
        xlabel('Scientific Benefit')
        ylabel('Lifecycle cost ($FY10M)')
        title(sprintf('%d NFE', nfeIntervals(nfe_i)))
        axis([0,0.35,0,4000])
        set(gca,'FontSize',14);
        legend('PF^*', '\epsilonMOEA','O-AOS','C-DNF','C-ACH', 'location','northwest')
    end
catch me
    clear ndPop iter
    eoss_java_end();
    disp(me.message);
end
clear ndPop iter
eoss_java_end();