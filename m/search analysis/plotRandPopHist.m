%Takes n random population histories and plots them out to show how the
%population evolves with time

n_representatives = 2;
path = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/AIAA JAIS/';
method = 'random/';

files = dir(strcat(path,method,'*.obj'));
ind = randi(length(files),n_representatives);

figure(1)
for i=1:n_representatives
    subplot(1,n_representatives,i);
    
    cla;
    tmp = strsplit(files(ind(i)).name,'.');
    tmp2 = strsplit(char(tmp(1)),'MOEA_');
    runName = char(tmp2(2));
    
    total_num_stages = 3;
    hold on
    labels ={};
    count = 1;
    for stage = total_num_stages : -1 :0
        data = csvread(strcat(path,method,runName,'_',num2str(stage),'_labels.csv'),1,0);
        scatter(-data(:,4),data(:,5)*33495.939796)
        labels{count} = sprintf('stage %d',stage);
        count = count + 1;
    end
    hold off
    xlabel('Scientific Benefit')
    axis([0,0.3,0,25000])
    set(gca,'FontSize',16);
end
subplot(1,n_representatives,1)
legend(labels)
ylabel('Lifecycle cost ($FY10M)')
