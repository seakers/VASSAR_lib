%this function will count the occurences of features and identify the ones
%that occur the most often


path = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/AIAA JAIS/aos_noFilter_noCross_x4/';
fid = fopen((strcat(path, filesep,'AIAA_innovize_feats_stage0.txt')));

single_feats = java.util.HashMap; %counts the occurences of single features
feature_arg_map = java.util.HashMap; %logs the arguments of each of the single features
combo_feat = java.util.HashMap; %counts the occurences of combined features

while(~feof(fid))
    line = fgetl(fid);
    feats = sort(strsplit(line, '],'));
    
    str = '';
    for i=1:length(feats)
        if strcmp(feats{i}(end),']')
            feats{i} = feats{i}(1:end-1);
        end
        m = regexp(feats{i}, '(?<pattern>[\w0-9]*)\[(?<args>.*)', 'names');
        str = strcat(str, m.pattern, ',');
        
        %add the occurence of the arguments to feature_arg_map
        if ~feature_arg_map.containsKey(m.pattern)
            feature_arg_map.put(m.pattern, java.util.ArrayList);
        end
%         args = strsplit(m.args,';');
%         args = args(~cellfun(@isempty,args));
%         
%       
%         for j = 1:length(args)
%             temp_args = strsplit(args{j},',');
%             for k=1:length(temp_args)
%                 if strcmp(temp_args{k},']')
%                     continue
%                 end
%                 feature_arg_map.get(m.pattern).add(temp_args{k});
%             end
%         end
        feature_arg_map.get(m.pattern).add(m.args);
        
        %add the occurence of the single pattern to single_feats
        if ~single_feats.containsKey(m.pattern)
            single_feats.put(m.pattern, 0);
        end
        single_feats.put(m.pattern, single_feats.get(m.pattern) + 1);
    end
    
    %add the occurence of the combination pattern to combo_feat
    if ~combo_feat.containsKey(str)
        combo_feat.put(str, 0);
    end
    combo_feat.put(str, combo_feat.get(str) + 1);
end
fclose(fid);

%print out the data
fprintf('Occurences of combination features:\n')
iter = combo_feat.keySet.iterator;
category = cell(combo_feat.keySet.size,1);
binCount = zeros(combo_feat.keySet.size,1);
i = 1;
while iter.hasNext
    combo = iter.next;
    category{i} = combo(1:end-1);
    binCount(i) = combo_feat.get(combo);
    fprintf('%60s:\t%3d\n',combo, combo_feat.get(combo));
    i=i+1;
end
figure(1)
[s_bin, s_i] = sort(binCount,1,'descend');
bar(s_bin);
set(gca,'XTick',1:length(category))
set(gca,'XTickLabel',category(s_i))
set(gca,'XTickLabelRotation',90)
set(gca,'FontSize',12)
title('Occurences of combination features')

fprintf('\nOccurences of single features:\n')
iter = single_feats.keySet.iterator;
category = cell(single_feats.keySet.size,1);
binCount = zeros(single_feats.keySet.size,1);
i=1;
while iter.hasNext
    feat = iter.next;
    category{i} = feat;
    binCount(i) = single_feats.get(feat);
    fprintf('%20s:\t%3d\n',feat, single_feats.get(feat));
    i=i+1;
end
figure(2)
[s_bin, s_i] = sort(binCount,1,'descend');
bar(s_bin/(3*120));
set(gca,'XTick',1:length(category))
set(gca,'XTickLabel',category(s_i))
set(gca,'XTickLabelRotation',90)
set(gca,'FontSize',12)
title('Occurences of single features')

fprintf('\nOccurences of arguments of single features:\n')
h3 = figure(3);
h4 = figure(4);

iter = single_feats.keySet.iterator;
feats = cell(single_feats.keySet.size,1);
i=1;
while iter.hasNext
    feats{i} = iter.next;
    i = i+1;
end

s_feats = sort(feats);
for j=1:length(feats)
    feat = s_feats{j};
    fprintf('\tOccurences of arguments for %s:\n',feat);
    count_sep = java.util.HashMap;
    count_together = java.util.HashMap;
    argArray = feature_arg_map.get(feat);
    argIter = argArray.iterator;
    while argIter.hasNext
        args = strsplit(argIter.next,', ');
        for i=1:length(args)
            arg = args{i};
            %add the occurence of the arguments to feature_arg_map
            if ~count_sep.containsKey(arg)
                count_sep.put(arg, 0);
            end
            count_sep.put(arg,count_sep.get(arg)+1);
        end
        
        s_args = strjoin(sort(args));
        if ~count_together.containsKey(s_args)
            count_together.put(s_args, 0);
        end
        count_together.put(s_args, count_together.get(s_args) + 1);
    end
    fprintf('\tArgument sentences\n')
    category = cell(count_together.keySet.size,1);
    binCount = zeros(count_together.keySet.size,1);
    iter2 = count_together.keySet.iterator;
    i=1;
    while iter2.hasNext
        args = iter2.next;
        category{i} = args;
        binCount(i) = count_together.get(args);
        fprintf('\t\t%25s:\t%3d\n',args, count_together.get(args));
        i=i+1;
    end
    figure(h3)
    subplot(2,ceil(single_feats.keySet.size/2),j)
    [s_bin, s_i] = sort(binCount,1,'descend');
    bar(s_bin);
    set(gca,'XTick',1:length(category))
    set(gca,'XTickLabel',category(s_i))
    set(gca,'XTickLabelRotation',90)
    set(gca,'FontSize',12)
    title(sprintf('%s',feat))
    
    
    category = cell(count_sep.keySet.size,1);
    binCount = zeros(count_sep.keySet.size,1);
    i=1;
    fprintf('\tSingle arguments\n')
    iter2 = count_sep.keySet.iterator;
    while iter2.hasNext
        arg = iter2.next;
        category{i} = arg;
        binCount(i) = count_sep.get(arg);
        fprintf('\t\t%20s:\t%3d\n',arg, count_sep.get(arg));
        i=i+1;
    end
    figure(h4)
    subplot(2,ceil(single_feats.keySet.size/2),j)
    [s_bin, s_i] = sort(binCount,1,'descend');
    bar(s_bin);
    set(gca,'XTick',1:length(category))
    set(gca,'XTickLabel',category(s_i))
    set(gca,'XTickLabelRotation',90)
    set(gca,'FontSize',12) 
    title(sprintf('%s',feat))
end