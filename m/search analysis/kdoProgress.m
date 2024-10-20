function kdoProgress
%looks at populations from the start of a data mining stage to the end of
%the data mining stage and compares the solutions found during the start
%and end by the kdo to another baseline algorithm


path = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/AIAA JAIS/';
jarpath = '/Users/nozomihitomi/Dropbox/EOSS/';

baseline = 'baseline';
kdo = 'aos_noFilter';

%load refPop to show Pareto front
load(strcat(path,'analysis/pop_final/refPop.mat'));
pfObj = objectives;
[~,pfInd] = sort(pfObj(:,1));

%nfe of the start and end of stages
stages = [0,1000,2000,3000,4000,5000];
stageLabels = cell(length(stages)-1,1);
for i=1:length(stages)-1
    stageLabels{i} = sprintf('%4d - %4d NFE',stages(i), stages(i+1));
end

colors = colormap('jet');
colors = colors([1,15,32,43,62],:);

figure(1)
subplot(1,2,1)
cla
hold on
files = dir(strcat(path,baseline,filesep,'*all.pop'));
ind = randi(length(files),1);
[objectives, nfe] = process(jarpath, strcat(path,filesep,baseline), files(ind).name);
for i=1:length(stages)-1
    ind = and(nfe>stages(i),nfe<stages(i+1));
    scatter(-objectives(ind,1),objectives(ind,2),10,colors(i,:));
end
plot(-pfObj(pfInd,1),pfObj(pfInd,2),'--k');
hold off
axis([0,0.3,0,25000])
xlabel('Scientific Benefit')
ylabel('Lifecycle cost ($FY10M)')
legend([stageLabels;'PF^*'])
set(gca,'FontSize',14);
title('baseline')

subplot(1,2,2)
cla
hold on
files = dir(strcat(path,kdo,filesep,'*all.pop'));
ind = randi(length(files),1);
[objectives, nfe] = process(jarpath, strcat(path,filesep,kdo), files(ind).name);
for i=1:length(stages)-1
    ind = and(nfe>stages(i),nfe<stages(i+1));
    scatter(-objectives(ind,1),objectives(ind,2),10,colors(i,:));    
end
axis([0,0.3,0,25000])
plot(-pfObj(pfInd,1),pfObj(pfInd,2),'--k');
hold off
xlabel('Scientific Benefit')
ylabel('Lifecycle cost ($FY10M)')
legend([stageLabels;'PF^*'])
set(gca,'FontSize',14);
title('kdo')

end


function [objectives, nfe] = process(jarpath, path, filename)
EOSS_init(jarpath);
origin = cd(path);
try
pop = architecture.io.ResultIO.loadPopulation(filename);
iter = pop.iterator;
popSize = pop.size;
objectives = zeros(popSize,2);
nfe = zeros(popSize,1);

i = 1;
h = waitbar(0, 'Processing solutions...');
while(iter.hasNext)
    solution = iter.next;
    objectives(i,:) = solution.getObjectives();
    nfe(i) = solution.getAttribute('NFE');
    i = i+1;
    waitbar(i/popSize, h);
end

catch me
    fprintf(me.message)
    clear solution iter pop
    cd(origin)
    close(h)
    EOSS_end(jarpath);
end
cd(origin)
clear solution iter pop
close(h)
EOSS_end(jarpath);

end