function [ops, credits] = readAndPlotOneCreditFileKDO()
%this function parses one of the .credit files created by mopAOS and plots
%the credit history. It also returns the credit history for each operator.
%ops are the operator names, credits is a two column vector for each
%operator


path = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/AIAA JAIS/';
respath = strcat(path,'aos_noFilter_noCross_x4');
origin = cd(respath);

files = dir('*.credit');
allcredits  = cell(length(files),1);
for i=1:length(files)
    expData = java.util.HashMap;
    fid = fopen(files(i).name,'r');
    while(feof(fid)==0)
        line = fgetl(fid);
        [~, endIndex] = regexp(line,'iteration,');
        raw_iteration = strsplit(line(endIndex+1:end),',');
        %need to split out the operator name
        line = fgetl(fid);
        [startIndex, endIndex] = regexp(line,'BitFlip,');
        if isempty(startIndex)
            [startIndex, endIndex] = regexp(line,'+ ,');
        end
        raw_credits = strsplit(line(endIndex+1:end),',');
        op_data = zeros(length(raw_iteration),2);
        for j=1:length(raw_credits)
            op_data(j,1)=str2double(raw_iteration{j}); %iteration
            op_data(j,2)=str2double(raw_credits{j}); %credit
        end
        %sometimes there is 0 iteration selection which is not valid
        op_data(~any(op_data(:,1),2),:)=[];
        if expData.keySet.contains(line(1:endIndex-1))
            expData.put(strcat(line(1:endIndex-1),num2str(rand(1))),op_data);
        else
            expData.put(line(1:endIndex-1),op_data);
        end
    end
    fclose(fid);
    allcredits{i} = expData;
end

numOps = 2;
numKDOOps = 4;

%plot
nepochs = 100;

maxEval = 5000;
epochLength = maxEval/nepochs;
all_epoch_credit_learned_ops = zeros(nepochs,1); %keeps track of the epoch credits from the operators
all_epoch_select_learned_ops = zeros(nepochs,1); %keeps track of the epoch selection count for the operators
all_epoch_credit_singlePoint = zeros(nepochs,1); %keeps track of the epoch credits from the operators
all_epoch_select_singlePoint = zeros(nepochs,1); %keeps track of the epoch selection count for the operators
all_epoch_credit = zeros(numOps, nepochs, length(files)); %keeps track of the epoch credits from the operators
all_epoch_select = zeros(numOps, nepochs, length(files)); %keeps track of the epoch selection count for the operators

for i=1:length(files)
    %collect all the raw data from all operators into one history
    raw_credits = zeros(maxEval, allcredits{i}.keySet.size-1);
    raw_selectFreq = zeros(maxEval, allcredits{i}.keySet.size-1);
    raw_select = zeros(maxEval,1);
    iter = allcredits{i}.keySet.iterator;
    k = 1;
    while(iter.hasNext)
        op = iter.next;
        if(strcmp(op,'OnePointCrossover+BitFlip'))
            continue;
        end
        hist = allcredits{i}.get(op);
        if size(hist,1)==0
            %means that the opeator was never selected
            continue;
        elseif size(hist,1) == 2 && size(hist, 2) == 1
            %sometimes the row vector gets flipped to column vector
            hist = hist';
        end
        raw_selectFreq(hist(:,1), k) = 1;
        raw_credits(hist(:,1), k) = hist(:,2);
        raw_select(hist(:,1)) = hist(:,1);
        k = k +1;
    end
    sumCredits = sum(raw_credits,2)/numKDOOps;
    sumSelect = sum(raw_selectFreq,2)/numKDOOps;
    
    %find the credits earned just by single point crossover
    single_point = allcredits{i}.get('OnePointCrossover+BitFlip');
        
         %sepearates out credits into their respective epochs
    for j=1:nepochs
        %First do the one point crossover
        %find indices that lie within epoch
        ind1 = epochLength*(j-1)<single_point(:,1);
        ind2 = single_point(:,1)<epochLength*j;
        epoch = single_point(and(ind1,ind2),:);
        if(~isempty(epoch(:,1))) %if it is empty then operator was not selected in the epoch
            all_epoch_credit_singlePoint(j)=mean( epoch(:,2));
            all_epoch_select_singlePoint(j) = length(unique(epoch(:,1)));
        end
        
        %Next do the learned operators
        %find indices that lie within epoch
        ind1 = epochLength*(j-1)<raw_select(:,1);
        ind2 = raw_select(:,1)<epochLength*j;
        epochCredits = sumCredits(and(ind1,ind2),:);
        epochSelect = sumSelect(and(ind1,ind2),:);
        if(~isempty(epochCredits)) %if it is empty then operator was not selected in the epoch
            all_epoch_credit_learned_ops(j) = mean(epochCredits);
            all_epoch_select_learned_ops(j) = sum(epochSelect);
        end
    end
    
    all_epoch_credit(1,:,i) = all_epoch_credit_singlePoint;
    all_epoch_credit(2,:,i) = all_epoch_credit_learned_ops;
    all_epoch_select(1,:,i) = all_epoch_select_singlePoint;
    all_epoch_select(2,:,i) = all_epoch_select_learned_ops;
end

colors = {
      [0         0.4470    0.7410]
    [0.8500    0.3250    0.0980]
    [0.9290    0.6940    0.1250]
    [0.4940    0.1840    0.5560]
    [0.4660    0.6740    0.1880]
    [0.3010    0.7450    0.9330]
    [0.6350    0.0780    0.1840]};

figure(1)
cla
handles = [];
maxCredit = 0;
for i=1:numOps
    X = [1:nepochs,fliplr(1:nepochs)];
    stddev = std(squeeze(all_epoch_credit(i,:,:)),0,2);
    mean_cred = mean(squeeze(all_epoch_credit(i,:,:)),2);
    Y = [mean_cred-stddev;flipud(mean_cred+stddev)];
    Y(Y<0) = 0; %correct for negative values
    %     fill(X,Y,colors{i},'EdgeColor','none');
    alpha(0.15)
    hold on
    handles = [handles plot([1:nepochs]-1,mean_cred,'Color',colors{i}, 'LineWidth',2)];
    maxCredit = max([max(mean_cred), maxCredit]);
end
plot([1,1],[-2,2],':k')
plot([20,20],[-2,2],':k')
plot([40,40],[-2,2],':k')
plot([60,60],[-2,2],':k')
plot([80,80],[-2,2],':k')

hold off
set(gca,'FontSize',16);
axis([0,nepochs, 0, maxCredit*1.1])
set(gca,'XTick',0:nepochs/5:nepochs);
set(gca,'XTickLabels',0:nepochs/5*epochLength:nepochs*epochLength);
xlabel('NFE')
ylabel('Credit earned')
legend(handles, 'Single-Point Crossover','KDO Operators');

figure(2)
cla
handles = [];
%normalize the selection to make it a probability
means = mean(all_epoch_select,3);
wts = [1,4];
mean_sum = wts*means;

for i=1:numOps
    mean_sel = means(i,:)./mean_sum;
    hold on
    handles = [handles, plot([2:nepochs]-1,mean_sel(2:end),'Color',colors{i}, 'LineWidth',2)];
end
plot([0,5000],[0.03,0.03],'--k')

plot([20,20],[-2,2],':k')
plot([40,40],[-2,2],':k')
plot([60,60],[-2,2],':k')
plot([80,80],[-2,2],':k')

legend(handles, 'Single-Point Crossover','KDO Operators');
axis([0, nepochs, 0, 1])
xlabel('NFE')
ylabel('Selection frequency')
set(gca,'XTick',0:nepochs/5:nepochs);
set(gca,'XTickLabels',0:nepochs/5*epochLength:nepochs*epochLength);
hold off
set(gca,'FontSize',16);
%save files
save('credit.mat','allcredits');

cd(origin);


end