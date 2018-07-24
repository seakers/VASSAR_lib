function [arch_pvals,exp_pvals,feature_counter] = countFeaturesOnPF(keyCol)

[narch,~] = size(keyCol{1});
nfiles = length(keyCol);

feature_counter = zeros(narch,41,nfiles);

for i = 1:nfiles
    keys = keyCol{i};
    for j = 1:narch
        arch = keys(j,:);
%         disp(num2str(arch(2:6)))
%         disp(num2str(arch(7:11)))
%         disp(num2str(arch(12:16)))
%         disp(num2str(arch(17:21)))
%         disp(num2str(arch(22:26)))
%         disp(' ')
        %has GEO?
        if arch(2) == 1
            feature_counter(j,1,i) = 1;
        end
        
        num=2;
        %find cross registered instruments
        for k=1:4 %loop over LEO
            for m=2:5 
                %if instrument m exisits in orbit j
                if arch(1+k*5+m) == 1
                    feature_counter(j,num,i) = 1;
                    num=num+1;
                else
                    num=num+5-m;
                    continue;
                end
                
                for n=m+1:5
                    %if instrument m and n are crossregistered in orbit j
                    if arch(1+k*5+n) == 1
                        feature_counter(j,num,i) = 1;
                    end
                    num=num+1;
                end
            end
        end
    end
end

%groups for full factorial 27 experiments
Agroup = [1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3];
Bgroup = [1,1,1,2,2,2,3,3,3,1,1,1,2,2,2,3,3,3,1,1,1,2,2,2,3,3,3];
Cgroup = [1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3];

all_data = zeros(narch*nfiles,41);
AgroupVector = zeros(narch*nfiles,1);
BgroupVector = zeros(narch*nfiles,1);
CgroupVector = zeros(narch*nfiles,1);

for i=1:nfiles
    all_data(narch*(i-1)+1:narch*i,:) = feature_counter(:,:,i);
    AgroupVector(narch*(i-1)+1:narch*i) = repmat(Agroup(i),narch,1);
    BgroupVector(narch*(i-1)+1:narch*i) = repmat(Bgroup(i),narch,1);
    CgroupVector(narch*(i-1)+1:narch*i) = repmat(Cgroup(i),narch,1);
end

%pvals comparing each architecture
arch_pvals = zeros(41,3);
for i=1:41
    arch_pvals(i,1) = anova1(all_data(:,i),AgroupVector,'off');
    arch_pvals(i,2) = anova1(all_data(:,i),BgroupVector,'off');
    arch_pvals(i,3) = anova1(all_data(:,i),CgroupVector,'off');
end

%pvals comparing each experiment
exp_pvals = zeros(41,3);
avg_num_features = reshape(mean(feature_counter,1),41,nfiles);
for i=1:41
    exp_pvals(i,1) = anova1(avg_num_features(i,:),Agroup,'off');
    exp_pvals(i,2) = anova1(avg_num_features(i,:),Bgroup,'off');
    exp_pvals(i,3) = anova1(avg_num_features(i,:),Cgroup,'off');
end