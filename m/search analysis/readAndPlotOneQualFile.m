function [ops, credits] = readAndPlotOneQualFile()
%this function parses one of the .qual files created by mopAOS and plots
%the quality history. It also returns the quality history for each operator.


path = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/ASC paper/';
respath = strcat(path,'new_emoea_operator_aos_checkChange_allSat_1Inst_eps_001_1');
origin = cd(respath);

files = dir('*.qual');

%aos parameters
beta = 0.8;
pmin = 0.03;


%get operator names
ops_set = java.util.HashSet;
fid = fopen(files(1).name,'r');
while(feof(fid)==0)
    %need to split out the operator name
    line = fgetl(fid);
    [startIndex, endIndex] = regexp(line,'[A-z\+]+,');
    %record the operator names
    ops_set.add(line(startIndex:endIndex-1));
end
iter = ops_set.iterator;
ops = cell(ops_set.size,1);
ops_map = java.util.HashMap;
i = 1;
while(iter.hasNext)
    ops{i} = iter.next;
    i = i + 1;
end
ops = sort(ops);
for i=1:length(ops);
    ops_map.put(ops{i},i);
end
numOps = length(ops);

%read data files
allquals = cell(length(files),numOps);
allprobs = cell(length(files),1);
for i=1:length(files)
    fid = fopen(files(i).name,'r');
    while(feof(fid)==0)
        %need to split out the operator name
        line = fgetl(fid);
        [startIndex, endIndex] = regexp(line,'[A-z\+]+,');
        raw_quals = strsplit(line(endIndex+1:end),',');
        op_data = zeros(length(raw_quals),1);
        for j=1:length(raw_quals)
            op_data(j)=str2double(raw_quals{j}); %quality
        end
        
        %record the operator names
        op_name = line(startIndex:endIndex-1);
        allquals{i,ops_map.get(op_name)} = op_data;
    end
    fclose(fid);
    
    %back compute the selection probabilities
    probs = zeros(size(op_data,1)+1,numOps);
    probs(i,:) = 1/numOps;
    pmax = (1-(numOps-1)*pmin);
    [~,ind] = max(cell2mat(allquals(i,:)),[],2);
    for j=2:size(op_data,1)+1
        maxInd = ind(j-1);
        probs(j,maxInd) = probs(j-1,maxInd) + beta * (pmax - probs(j-1,maxInd));
        
        otherInd = true(1,numOps);
        otherInd(maxInd) = false;
        probs(j,otherInd) = probs(j-1,otherInd) + beta * (pmin - probs(j-1,otherInd));
    end
    allprobs{i} = probs;
end

for i=1:length(files)
    plot(allprobs{i})
    legend(ops)
end


%plot
nepochs = 100;

maxEval = 5000;
epochLength = maxEval/nepochs;
all_epoch_qual = zeros(expData.keySet.size, nepochs, length(files)); %keeps track of the epoch quality from the operators

for i=1:length(files)
    for k = 1:numOps
        hist = allquals{i}.get(ops{k});
        if size(hist,1)==0
            %means that the opeator was never selected
            continue;
        elseif size(hist,1) == 2 && size(hist, 2) == 1
            %sometimes the row vector gets flipped to column vector
            hist = hist';
        end
        %sepearates out credits into their respective epochs
        for j=1:nepochs
            %find indices that lie within epoch
            ind1 = epochLength*(j-1)<hist(:,1);
            ind2 = hist(:,1)<epochLength*j;
            epoch = hist(and(ind1,ind2),:);
            if(~isempty(epoch(:,1))) %if it is empty then operator was not selected in the epoch
                all_epoch_qual(k, j, i) = mean(epoch(:,2));
            end
        end
    end
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
maxQuality = 0;
for i=1:numOps
    X = [1:nepochs,fliplr(1:nepochs)];
    stddev = std(squeeze(all_epoch_qual(i,:,:)),0,2);
    mean_cred = mean(squeeze(all_epoch_qual(i,:,:)),2);
    Y = [mean_cred-stddev;flipud(mean_cred+stddev)];
    Y(Y<0) = 0; %correct for negative values
    %     fill(X,Y,colors{i},'EdgeColor','none');
    alpha(0.15)
    hold on
    handles = [handles plot(1:nepochs,mean_cred,'Color',colors{i}, 'LineWidth',2)];
    maxQuality = max([max(mean_cred), maxQuality]);
end
hold off
set(gca,'FontSize',16);
axis([0,nepochs, 0, maxQuality*1.1])
set(gca,'XTick',0:nepochs/10:nepochs);
set(gca,'XTickLabels',0:nepochs/10*epochLength:nepochs*epochLength);
xlabel('NFE')
ylabel('Quality')
legend(handles, ops);

cd(origin);


end