%plots the boxplots of the search performance metrics (i.e. fast hypervolume
%(jmetal)) for each algorithm
problemName = {''};
selectors = {'AdaptivePursuit'};
selectorShort = {'AP'};

% creditDef = {'SI-PF_oneCross','SI-PF_allCross','SI-PF_moreCross','SI-PF_moreCross2','SI-PF_moreCrossNoInter'};
creditDef = {'SI-A_moreCrossNoInter10','SI-A_moreCrossNoInterNoSingle10'};

path = 'C:\Users\SEAK2\Nozomi\EOSS\problems\climateCentric\search performance';
mres_path =strcat(path,filesep,'mRes');
% res_path = '/Users/nozomihitomi/Desktop/untitled folder';

b = length(selectors)*length(creditDef);

h1 = figure(1); %fHV history
clf(h1)
h2 = figure(2); %fHV final
clf(h2)
h3 = figure(3); %average evaluations needed to reach target HV

statsfHV = zeros(length(problemName),b,3);
testAlg = 'EpsilonMOEA';
% testAlg = 'Random';

minHV = 2;
targetHV = 2+0.80*(2.55-2);

for i=1:length(problemName)
    probName = problemName{i};
    [allfHV,~] = getBenchmarkVals(path,'allfHV');
    figure(1)
    
    [benchmarkDatafHV,label_names] = getBenchmarkVals(path,'fHV');
    label_names_fHV={};
    %box plot colors for benchmarks
    boxColors = 'rkbm';
    
    evals2TargetHV = zeros(size(allfHV{1},2),length(benchmarkDatafHV));
    
    datafHV = benchmarkDatafHV{1}';
    plot(1:length(allfHV{1}),mean(allfHV{1},2))
    hold on
    for j=2:length(benchmarkDatafHV)
        datafHV = cat(2,datafHV,benchmarkDatafHV{j}');
        plot(1:length(allfHV{1}),mean(allfHV{j},2))
    end
    
    [a,c] = size(datafHV);
    
    %compute average evaluations needed to reach target HV
    for j = 1:length(allfHV)
        tmp = allfHV{j};
        for k = 1:a
            evals2TargetHV(k,j)= find(tmp(:,k)<targetHV,1,'last');
        end
    end
    
    %test benchmark performance against test algorithm
    for j=1:c
        [p,sig] = runMWUsignificance(path,strcat(path,filesep,'Benchmarks'),label_names{j},'',testAlg);
        
        extra = '';
        if sig.fHV==1
            extra = '(+)';
            statsfHV(i,c,1) = 1;
        elseif sig.fHV==-1
            extra = '(-)';
            statsfHV(i,c,3) = 1;
        else
            statsfHV(i,c,2) = 1;
        end
        label_names_fHV = {label_names_fHV{:},strcat(label_names{j},extra)}; %concats the labels
        boxColors = strcat(boxColors,'b');
    end
    

    datafHV = cat(2,datafHV,zeros(a,b));
    
    evals2TargetHV = cat(2,evals2TargetHV,zeros(a,b));
    
    for j=1:length(selectors)
        for k=1:length(creditDef)
            c = c+1;
            file = strcat(mres_path,filesep,selectors{j},'_',creditDef{k},'.mat');
            load(file,'res'); %assume that the reults stored in vairable named res
            %             plot(26:225,mean(res.allfHV,2))
            plot(mean(res.allfHV,2))
            
            datafHV(:,c) = res.fHV';
            
            %compute average evaluations needed to reach target HV
            for m = 1:a
                evals2TargetHV(m,c)= find(res.allfHV(:,m)<targetHV,1,'last');
            end
            
            [p,sig] = runMWUsignificance(path,mres_path,selectors{j},creditDef{k},testAlg);
            
            extra = '';
            if sig.fHV==1
                extra = '(+)';
                statsfHV(i,c,1) = 1;
            elseif sig.fHV==-1
                extra = '(-)';
                statsfHV(i,c,3) = 1;
            else
                statsfHV(i,c,2) = 1;
            end
            label_names_fHV = {label_names_fHV{:},strcat(selectorShort{j},'-',creditDef{k},extra)}; %concats the labels
            boxColors = strcat(boxColors,'b');
        end
    end
    
    hold off
    legend(label_names_fHV)
    title('Hypervolume history')
    
    
    figure(h2)
    ha = gca;
    [~,ind]=max(mean(datafHV,1));
    label_names_fHV{ind} = strcat('\bf{',label_names_fHV{ind},'}');
    boxplot(datafHV,label_names_fHV,'colors',boxColors,'boxstyle','filled','medianstyle','target','symbol','+')
    set(ha,'TickLabelInterpreter','tex');
    set(ha,'XTickLabelRotation',0);
    set(ha,'FontSize',13);
    
    
    figure(h3)
    ha = gca;
    [~,ind]=min(mean(evals2TargetHV,1));
    label_names_fHV{ind} = strcat('\bf{',label_names_fHV{ind},'}');
    boxplot(evals2TargetHV,label_names_fHV,'colors',boxColors,'boxstyle','filled','medianstyle','target','symbol','+')
    set(ha,'TickLabelInterpreter','tex');
    set(ha,'XTickLabelRotation',0);
    set(ha,'FontSize',13);
    
end

statsfHV = squeeze(sum(statsfHV,1))
disp('mean time')
% %
