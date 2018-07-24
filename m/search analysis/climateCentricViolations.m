function climateCentricViolations(datafile)

%load the file
load(datafile)
str = strsplit(datafile,filesep);
str2 = strsplit(str{end},'.');
filename = str2{1};

massThreshold = 3000;
dutyCycleThreshold = 0.5;
packingEfficiencyThreshold = 0.4;

%compute the violations for each constraint
violations = zeros(length(nfe),6);

%satellites that are active
satsOnOff = dutyCycle > 0;
nSatsOn = sum(satsOnOff,2);

%compute duty cycle violation
vd = zeros(size(dutyCycle,1),size(dutyCycle,2));
vd(satsOnOff) = (dutyCycleThreshold-dutyCycle(satsOnOff))/dutyCycleThreshold;
vd(vd<0) = 0; %for the satellites that meet the threshold
vd(vd==1) = 0; %for the satellites with no instruments
violations(:,1) = sum(vd,2)./nSatsOn;
violations(:,2) = instorb;
violations(:,3) = interference;
%compute mass violations
vm = (mass-massThreshold)./abs(mass);
vm(vm<0) = 0;
violations(:,4) = sum(vm,2)./nSatsOn;
%compute packing efficiency violation
ind = isnan(packingEfficiency);
packingEfficiency(ind) = 0;
vpe = zeros(size(packingEfficiency,1),size(packingEfficiency,2));
vpe(satsOnOff) = (packingEfficiencyThreshold-packingEfficiency(satsOnOff))/packingEfficiencyThreshold;
vpe(vpe<0) = 0; %for the satellites that meet the threshold
vpe(vpe==1) = 0; %for the satellites with no instruments
violations(:,5) = sum(vpe,2)./nSatsOn;
violations(:,6) = synergy;

%violations for empty architecture is 0
violations(isnan(violations)) = 0;

%compute the solutions with any violations over nfe
uniqueNFE = unique(nfe);
anyViolation = zeros(length(unique(nfe)),6);
for i=2:length(uniqueNFE)
    ind = and(nfe > uniqueNFE(i-1), nfe <= uniqueNFE(i));
    for j =1:6
        temp = violations(ind,j);
        anyViolation(i-1,j) = sum(temp>0)/sum(ind);
    end
end

%compute the average violation in the population over nfe
meanViolation = zeros(length(unique(nfe)),6);
for i=2:length(uniqueNFE)
    ind = and(nfe > uniqueNFE(i-1), nfe <= uniqueNFE(i));
    for j =1:6
        meanViolation(i-1,j) = mean(violations(ind,j));
    end
end


constraints = {'Instrument duty cycle','Instrument orbit relationships',...
    'Interfering instrument pairs','Spacecraft Mass','Packing efficiency',...
    'Synergistic instrument pairs'};
m = colormap('jet');

%plot fraction of solutions with any violation (smooth signal)
h = figure(1);
cla
windowSize = 50;
wts = ones(1,windowSize)/windowSize;
ind = uniqueNFE > 200;
hold on
for i=1:6
    v = filter(wts,1,anyViolation(:,i));
    plot(uniqueNFE(ind) - windowSize/2,v(ind));
end
set(gca,'FontSize',16)
legend(constraints)
xlabel('NFE')
ylabel('Fraction of Solutions with any violation')
axis([0,5000,0,1])
saveas(h, strcat(filename, '_any_violations_history.fig'))
saveas(h, strcat(filename, '_any_violations_history.png'))

%plot sum of violations in population
h = figure(2);
cla
windowSize = 50;
wts = ones(1,windowSize)/windowSize;
hold on
for i=1:6
    v = filter(wts,1,meanViolation(:,i));
    plot(uniqueNFE(ind) - windowSize/2,v(ind));
end
set(gca,'FontSize',16)
legend(constraints)
xlabel('NFE')
ylabel('Mean violation')
axis([0,5000,0,1])
saveas(h, strcat(filename, '_mean_violations_history.fig'))
saveas(h, strcat(filename, '_mean_violations_history.png'))

%plot heat map of violations in objective space
h = figure(3);
cla
for i=1:size(violations,2)
    subplot(3,2,i)
    scatter(-objectives(:,1),objectives(:,2), 5, violations(:,i));
    colormap(m(11:end,:))
    colorbar
    xlabel('Scientific Benefit')
    ylabel('Lifecycle cost ($FY10M)')
    title(constraints{i})
    axis([0,0.35, 0, 2.5e4])
    set(gca,'FontSize',14)
end
saveas(h, strcat(filename, '_violations_map.fig'))
saveas(h, strcat(filename, '_violations_map.png'))

h = figure(4);
cla
scatter(-objectives(:,1),objectives(:,2), 5, sum(violations,2));
set(gca,'FontSize',16)
colormap(m(11:end,:))
c = colorbar;
c.Label.String = 'Violations';
xlabel('Scientific Benefit')
ylabel('Lifecycle cost ($FY10M)')
axis([0,0.35, 0, 2.5e4])
saveas(h, strcat(filename, '_violations_sum_map.fig'))
saveas(h, strcat(filename, '_violations_sum_map.png'))

%plot heat map of nfe in objective space
h = figure(5);
cla
scatter(-objectives(:,1),objectives(:,2), 5, nfe);
set(gca,'FontSize',16)
colormap(m(11:end,:))
c = colorbar;
xlabel('Scientific Benefit')
ylabel('Lifecycle cost ($FY10M)')
c.Label.String = 'NFE';
axis([0,0.35, 0, 2.5e4])
saveas(h, strcat(filename, '_NFE_map.fig'))
saveas(h, strcat(filename, '_NFE_map.png'))



