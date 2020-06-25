function [feature_names, feature_stats, before, after] = kdoFeaturePerformanceAnalysis()
%this function compiles the features extracted at different stages of the
%search and compiles information about their support, confidence, and how
%the AOS handles each feature.

jarpath = '/Users/nozomihitomi/Dropbox/EOSS/';
path = strcat(jarpath, filesep, 'problems',filesep, 'climateCentric');
filepath = strcat(path, filesep, 'result', filesep, 'AIAA JAIS', filesep, 'aos_noFilter_noCross_x4');

n_ops = 4;
n_stages = 5;

try
    EOSS_init(jarpath);
    origin = cd(filepath);
    files = dir('*.credit');
    
     %initialize EOSSDatabase
     db = eoss.problem.EOSSDatabase.getInstance();
     eoss.problem.EOSSDatabase.loadBuses(java.io.File(strcat(path,filesep,'config',filesep,'candidateBuses.xml')));
     eoss.problem.EOSSDatabase.loadInstruments(java.io.File(strcat(path,filesep,'xls',filesep,'Instrument Capability Definition.xls')));
     eoss.problem.EOSSDatabase.loadOrbits(java.io.File(strcat(path,filesep,'config',filesep,'candidateOrbits.xml')));
     opCreator =  knowledge.operator.EOSSOperatorCreator;
    
    %find unique ids
    unique_ids = java.util.HashSet;
    for i=1:length(files)
        m = regexp(files(i).name, 'aos_(?<id>[0-9]*)*', 'names');
        unique_ids.add(m.id);
    end
    
    feature_names = cell(n_stages*n_ops,unique_ids.size());
    feature_stats = zeros(n_stages*n_ops,8,unique_ids.size());%b_sup,b_conf,a_sup,a_conf,select,credit
    before = cell(n_stages*n_ops,1);%b_sup,b_conf,a_sup,a_conf,select,credit
    after = cell(n_stages*n_ops,1);%b_sup,b_conf,a_sup,a_conf,select,credit
    file_i = 1;
    
    iter = unique_ids.iterator;
    while(iter.hasNext)
        f_tmp = iter.next;
        
        %process credit file
        credit_file = dir(sprintf('*%s*.credit',f_tmp));
        expData = java.util.HashMap;
        fid = fopen(credit_file.name,'r');
        while(feof(fid)==0)
            line = fgetl(fid);
            [~, endIndex] = regexp(line,'iteration,');
            raw_iteration = strsplit(line(endIndex+1:end),',');
            %need to split out the operator name
            line = fgetl(fid);
            m = regexp(line,'OnePointCrossover\s\+\s(?<name>[\w\s\=,0-9\+\-\{\}\[\]]*) \+ ,(?<credit>[0-9\.,]+)', 'names');
            if isempty(m)
                %then it is the single point crossover + bitflip
                m = regexp(line,'(?<name>OnePointCrossover)[\s\+]*BitFlip,(?<credit>[0-9\.,]+)', 'names');
            end
            raw_credits = strsplit(m.credit,',');
            op_data = zeros(length(raw_iteration),2);
            for j=1:length(raw_credits)
                op_data(j,1)=str2double(raw_iteration{j}); %iteration
                op_data(j,2)=str2double(raw_credits{j}); %credit
            end
            %sometimes there is 0 iteration selection which is not valid
            op_data(op_data(:,1)==0,:)=[];
            expData.put(m.name,op_data);
        end
        fclose(fid);
        
        figure(1)
        counter = 1;
        for stage_i = 0:n_stages - 1
            feature_file = dir(sprintf('*%s_%d_features.txt',f_tmp,stage_i));
            label_before = dir(sprintf('*%s_%d_labels.csv',f_tmp,stage_i));
            before_ind_file = dir(sprintf('*%s_%d_features_ind.csv',f_tmp,stage_i));
%             label_after = dir(sprintf('*%s_%d_labels.csv',f_tmp,stage_i+1));
%             after_ind_file = dir(sprintf('*%s_%d_features_ind.csv',f_tmp,stage_i+1));
            
            %find which solutions conform to the rules
            ind_before = logical(csvread(before_ind_file.name,1,0)');
%             ind_after = logical(csvread(after_ind_file.name,1,0)');
            
            %get the human-readable string for the rules
            fid = fopen(before_ind_file.name,'r');
            line = fgetl(fid);
            fclose(fid);
            rule_string = strsplit(line,'||');
            
            %get the computer-syntax string for the rules
            fid = fopen(feature_file.name,'r');
            fgetl(fid); %skip first header line
            rule_code = cell(n_ops,1);
            rule_code_i = 1;
            while(feof(fid)==0)
                line = fgetl(fid);
                tmp = strsplit(line,'/');
                rule_code{rule_code_i} = tmp{1};
                rule_code_i = rule_code_i + 1;
            end
            fclose(fid);
            
            data_before = csvread(label_before.name,1,0);
            good_before = logical(data_before(:,1));
            
%             data_after = csvread(label_after.name,1,0);
%             good_after = logical(data_after(:,1));
            
            for feature_j = 1:n_ops
                feature_names(counter,file_i) = rule_string(feature_j);
                
                before{counter,file_i} = ind_before(:,feature_j);
%                 after{counter,file_i} = ind_before(:,feature_j);
                
                %compute support and confidence at beginning and end of data mining stage
                feature_stats(counter,1,file_i) = sum(ind_before(:,feature_j))/length(good_before);
                feature_stats(counter,2,file_i) = sum(and(good_before, ind_before(:,feature_j)))/length(good_before);
                feature_stats(counter,3,file_i) = sum(and(good_before, ind_before(:,feature_j)))/sum(ind_before(:,feature_j));
%                 feature_stats(counter,4,file_i) = sum(ind_after(:,feature_j))/length(good_after);
%                 feature_stats(counter,5,file_i) = sum(and(good_after, ind_after(:,feature_j)))/length(good_after);
%                 feature_stats(counter,6,file_i) = sum(and(good_after, ind_after(:,feature_j)))/sum(ind_after(:,feature_j));
                
                subplot(n_stages,n_ops,stage_i * n_ops + feature_j)
                scatter(-data_before(:,63),data_before(:,64),5,ones(1,3)*.8);
                hold on
                scatter(-data_before(good_before,63),data_before(good_before,64),5,'m','filled');
                scatter(-data_before(ind_before(:,feature_j),63),data_before(ind_before(:,feature_j),64),4,'b','filled');
                hold off
                axis([0,0.3,0,25000]) 
                legend('All Solutions','Top 25%',sprintf('Rule %d',feature_j))
                
                %record feature's num times selected and its credits
                op = opCreator.featureToOperator(rule_code{feature_j});
                opData = expData.get(op.toString);
                %sometimes column vector gets rotated to row vector if there
                %feature was only used once
                if size(opData,2) == 1
                    opData = opData';
                end
                
                if(isempty(opData))
                    fprintf('\n\nfile: %s, op: %s\n\n', feature_file.name,char(op.toString));
                else
                    feature_stats(counter,7,file_i) = length(opData(:,1));
                    feature_stats(counter,8,file_i) = sum(opData(:,2));
                end
                counter = counter + 1;
            end
        end
        file_i = file_i + 1;
%           pause
    end
    
catch me
    cd(origin)
    clear opCreator unique_ids expData db op iter
    EOSS_end(jarpath);
    rethrow(me)
end
cd(origin)
clear opCreator unique_ids expData db op iter
EOSS_end(jarpath);