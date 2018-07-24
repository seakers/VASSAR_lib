function [data,PF_ind,feature_inds,keyCol] = load_result_features

resMngr = rbsa.eoss.ResultManager.getInstance();
ATE = rbsa.eoss.ArchTradespaceExplorer.getInstance();

%open all results files that need to analyzed
[FileName,PathName,~] = uigetfile( './*.rs*','MultiSelect','on');

numFiles = length(FileName);
data = cell(numFiles,1);
out = zeros(numFiles,44);
PF_ind = cell(numFiles,1);
feature_inds = cell(numFiles,1);
keyCol = cell(numFiles,1);
for i=1:numFiles
    %load file
    resCol = resMngr.loadResultCollectionFromFile( [PathName FileName{i}] );
    results = resCol.getResults;
    
    narch = results.size;
    xvals = zeros(narch,1);
    yvals = zeros(narch,1);
    for j = 1:narch
        xvals(j) = results.get(j-1).getScience;
        yvals(j) = results.get(j-1).getCost;
    end
    [~,~,ind] = NSGA2Selection(xvals,yvals,500);
    lastGen = java.util.ArrayList;
    for j=1:length(ind)
        lastGen.add(results.get(ind(j)-1));
    end
%     lastGen = results;
    
    %gather the data from the population
    narch = lastGen.size;
    sci = zeros(narch,1);
    cost = zeros(narch,1);
    features = zeros(narch,11);
    feat_inds = false(narch,10);
    keys = zeros(narch,26);
    for j = 1:narch
        sci(j) = lastGen.get(j-1).getScience;
        cost(j) = lastGen.get(j-1).getCost;
        arch = lastGen.get(j-1).getArch;
        feat = zeros(1,11);
        
        bitString = double(arch.getBitString)';       
        numSat = arch.getNsats;
        key = mat2str([numSat,bitString]);
        keys(j,:) = [numSat,bitString];
        
        feat(1) = numSat;
        if hasGEO(key)
            feat(2) = 1;
            feat_inds(j,1) = true;
        end
        if hasATMS(key)
            feat(3) = 1;
            feat_inds(j,2) = true;
        end
        if has50(key)
            feat(4) = 1;
            feat_inds(j,3) = true;
        end
        if has118(key)
            feat(5) = 1;
            feat_inds(j,4) = true;
        end
        if has183(key)
            feat(6) = 1;
            feat_inds(j,5) = true;
        end
        if inGEO(key)
            feat(7) = 1;
            feat_inds(j,6) = true;
        end
        if in600ISS(key)
            feat(8) = 1;
            feat_inds(j,7) = true;
        end
        if in600SSO(key)
            feat(9) = 1;
            feat_inds(j,8) = true;
        end
        if in800AM(key)
            feat(10) = 1;
            feat_inds(j,9) = true;
        end
        if in800PM(key)
            feat(11) = 1;
            feat_inds(j,10) = true;
        end
        
        features(j,:) = feat;
    end
    
    keyCol{i} = keys;
    
    %find PF
    [~, ~, inds, ~ ] = pareto_front([sci cost] , {'LIB', 'SIB'});
    tmp = zeros(narch,1);
    tmp(inds) = 1;
    PF_ind{i} = logical(tmp);
    num_on_PF = sum(PF_ind{i});
    
    feature_inds{i} = feat_inds;
    
    disp('feature: GEO, ATMS, 50, 118, 183, inGEO, in600ISS, in600SSO, in800AM, in800PM')
    fprintf('%% with feature in population: \n')
    feat_in_pop = sum(features(:,2:11),1)/narch;
    fprintf('%d\t',feat_in_pop)
    on_PF_with_feat = zeros(1,10);
    with_feat_on_PF = zeros(1,10);
    for j=1:10
         on_PF_with_feat(j) = sum(feat_inds(:,j) & PF_ind{i})/num_on_PF;
         with_feat_on_PF(j) = sum(feat_inds(:,j) & PF_ind{i})/sum(feat_inds(:,j));
    end
    fprintf('\n%% on PF with feature: \n')
    fprintf('%d\t',on_PF_with_feat)
    fprintf('\n%% with feature on PF: \n')
    fprintf('%d\t',with_feat_on_PF)
    
    average_sat_plane_pop = sum(features(:,1))/narch;
    fprintf('\naverage satellites per plane in population: %d\n',average_sat_plane_pop);
    average_sat_plane_PF =sum(features(PF_ind{i},1))/num_on_PF;
    fprintf('average satellites per plane on PF %d\n',average_sat_plane_PF);
    
    satSizes = zeros(narch,5);
    ninst = zeros(narch,1);
    for j=1:narch
        bitString = double(lastGen.get(j-1).getArch.getBitString);  
        satSizes(j,:) = [sum(bitString(1:5)),sum(bitString(6:10)),sum(bitString(11:15)),sum(bitString(16:20)),sum(bitString(21:25))];
        ninst(j) = sum(satSizes(j,:));
    end
    fprintf('average satellite sizes in population: \n')
    avg_sat_size_pop = sum(satSizes,1)/narch;
    fprintf('%d\t',avg_sat_size_pop);
    fprintf('\naverage satellite sizes on PF \n')
    avg_sat_size_PF = sum(satSizes(PF_ind{i},:),1)/num_on_PF;
    fprintf('%d\t',avg_sat_size_PF);
    avg_ninst_pop = sum(ninst)/narch;
    fprintf('average num of instruments per sat in population: %d\n',avg_ninst_pop);
    avg_ninst_PF = sum(ninst(PF_ind{i}))/num_on_PF;
    fprintf('average num of instruments per sat on PF %d\n\n',avg_ninst_PF);
    
    data{i} = [sci,cost,features];
    out(i,:) = [feat_in_pop,on_PF_with_feat,with_feat_on_PF,average_sat_plane_pop,average_sat_plane_PF...
        avg_sat_size_pop,avg_sat_size_PF,avg_ninst_pop,avg_ninst_PF];
end

csvwrite('PFAnalysis.csv',out);

function bool = isEmptyArch(bitString)
bool = (bitString(1)==0);

function [bool] = hasATMS(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch has ATMS
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([6,11,16,21,26]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end
    

function [bool] = hasGEO(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch has ATMS
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if bitString(2)==1
    bool = true;
end

function [bool] = has50(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch has EON_50
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([3,8,13,18,23]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end


function [bool] = has118(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch has EON_118
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([4,9,14,19,24]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end

function [bool] = has183(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch has EON_183
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([5,10,15,20,25]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end

function [bool] = inGEO(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch occupies GEO
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([2,3,4,5,6]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end

function [bool] = in600ISS(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch occupies 600km ISS inc
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([7,8,9,10,11]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end

function [bool] = in600SSO(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch occupies 600km SSO
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([12,13,14,15,16]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end

function [bool] = in800AM(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch occupies 800km SSO AM
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([17,18,19,20,21]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end

function [bool] = in800PM(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns true if arch occupies 800km SSO PM
bool = false;
bitString = str2num(bitStringKey);
if isEmptyArch(bitString)
    return;
end
if sum(bitString([22,23,24,25,26]))>0
    %if sum is greater than zero there is at least one ATMS
    bool=true;
end
