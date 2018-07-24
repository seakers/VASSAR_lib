function [GEO_archs, EON_50_archs, EON_118_archs, EON_183_archs,ATMS_archs] = analyze_dist_to_PF(keySet,dist2PFMat)
%run the analysis after running dist_to_paretofront
%This will create more stats for running anova
%Returns archs grouped by features and the corresponding distances to the
%pareto front.

archs = cell(length(keySet),1);
for i=1:length(keySet)
    bitStringKey = keySet{i};
    arch.bitString = bitStringKey;
    arch.dist2PF = dist2PFMat(i,:);
    
    arch.hasGEO = hasGEO(bitStringKey);
    arch.hasATMS = hasATMS(bitStringKey);
    arch.has50 = has50(bitStringKey);
    arch.has118 = has118(bitStringKey);
    arch.has183 = has183(bitStringKey);
    
    arch.inGEO = inGEO(bitStringKey);
    arch.in600ISS = in600ISS(bitStringKey);
    arch.in600SSO = in600SSO(bitStringKey);
    arch.in800AM = in800AM(bitStringKey);
    arch.in800PM = in800PM(bitStringKey);
    
    arch.numSat = satellitesPerPlane(bitStringKey);
    
    archs{i}=arch;
    clear arch;
end

%puts archs into bins. A arch may fit into more than one bin
GEO_archs = cell(length(keySet),1);
ATMS_archs = cell(length(keySet),1);
EON_50_archs = cell(length(keySet),1);
EON_118_archs = cell(length(keySet),1);
EON_183_archs = cell(length(keySet),1);
inGEO_archs = cell(length(keySet),1);
in600ISS_archs = cell(length(keySet),1);
in600SSO_archs = cell(length(keySet),1);
in800SSOAM_archs = cell(length(keySet),1);
in800SSOPM_archs = cell(length(keySet),1);
nSat_archs = cell(length(keySet),9);

for i=1:length(archs)
    arch = archs{i};
    if arch.hasGEO
        GEO_archs{i} = arch;
    end
    if arch.hasATMS
        ATMS_archs{i} = arch;
    end
    if arch.has50
        EON_50_archs{i} = arch;
    end
    if arch.has118
        EON_118_archs{i} = arch;
    end
    if arch.has183
        EON_183_archs{i} = arch;
    end
    if arch.inGEO
        inGEO_archs{i} = arch;
    end
    if arch.in600ISS
        in600ISS_archs{i} = arch;
    end
    if arch.in600SSO
        in600SSO_archs{i} = arch;
    end
    if arch.in800AM
        in800SSOAM_archs{i} = arch;
    end
    if arch.in800PM
        in800SSOPM_archs{i} = arch;
    end
    
    nsat = arch.numSat;
    nSat_archs{i,nsat} = arch;
end

%get rid of empty cells
GEO_archs = GEO_archs(~cellfun('isempty',GEO_archs));
ATMS_archs = ATMS_archs(~cellfun('isempty',ATMS_archs));
EON_50_archs = EON_50_archs(~cellfun('isempty',EON_50_archs));
EON_118_archs = EON_118_archs(~cellfun('isempty',EON_118_archs));
EON_183_archs = EON_183_archs(~cellfun('isempty',EON_183_archs));
inGEO_archs = inGEO_archs(~cellfun('isempty',inGEO_archs));
in600ISS_archs = in600ISS_archs(~cellfun('isempty',in600ISS_archs));
in600SSO_archs = in600SSO_archs(~cellfun('isempty',in600SSO_archs));
in800SSOAM_archs = in800SSOAM_archs(~cellfun('isempty',in800SSOAM_archs));
in800SSOPM_archs = in800SSOPM_archs(~cellfun('isempty',in800SSOPM_archs));

%find average distance to pareto front over results in same experiment
[avgDistGEO,stdDistGEO,dataGEO] = getAverageDistances(GEO_archs);
[avgDistATMS,stdDistATMS,dataATMS] = getAverageDistances(ATMS_archs);
[avgDist50,stdDist50,data50] = getAverageDistances(EON_50_archs);
[avgDist118,stdDist118,data118] = getAverageDistances(EON_118_archs);
[avgDist183,stdDist183,data183] = getAverageDistances(EON_183_archs);
[avgDistinGEO,stdDistinGEO,datainGEO] = getAverageDistances(inGEO_archs);
[avgDistin600ISS,stdDistin600ISS,datain600ISS] = getAverageDistances(in600ISS_archs);
[avgDistin600SSO,stdDistin600SSO,datain600SSO] = getAverageDistances(in600SSO_archs);
[avgDistin800SSOAM,stdDistin800SSOAM,datain800SSOAM] = getAverageDistances(in800SSOAM_archs);
[avgDistin800SSOPM,stdDistin800SSOPM,datain800SSOPM] = getAverageDistances(in800SSOPM_archs);

allStats.averages = {avgDistGEO,avgDistATMS,avgDist50,avgDist118,...
    avgDist183,avgDistinGEO,avgDistin600ISS,avgDistin600SSO...
    avgDistin800SSOAM,avgDistin800SSOPM};
allStats.stddev = {stdDistGEO,stdDistATMS,stdDist50,stdDist118,...
    stdDist183,stdDistinGEO,stdDistin600ISS,stdDistin600SSO...
    stdDistin800SSOAM,stdDistin800SSOPM};
allStats.data = {dataGEO,dataATMS,data50,data118,data183,datainGEO,datain600ISS...
    datain600SSO,datain800SSOAM,datain800SSOPM};

feature_label = {'hasGEO','hasATMS','has50','has118','has183','inGEO','in600ISS','in600SSO','in800SSOAM','in800SSOPM'};

load('L18StdOrthoMatrix.mat');
[nrow,ncol] = size(L18StdOrthoMatrix);

disp('avg distances to pareto front')
for i=1:length(feature_label)
    fprintf('%s\t\t',feature_label{i})
    avg_distances =  allStats.averages{i};
    for j=1:nrow
        fprintf('%d\t',avg_distances(j));
    end
    fprintf('\n');
end
fprintf('\n');

disp('std dev distances to pareto front')
for i=1:length(feature_label)
    fprintf('%s\t\t',feature_label{i})
    std_distances =  allStats.stddev{i};
    for j=1:nrow
        fprintf('%d\t',std_distances(j));
    end
    fprintf('\n');
end
fprintf('\n');

%do ANOVA one way analysis on available data
disp('pvals of distances pareto front across experiments')
for i=1:length(feature_label)
    fprintf('%s\t\t',feature_label{i})
    
    stat_data = [];
    all_data = allStats.data{i};
    for j=1:nrow
        exp_data = cell2mat(all_data{j});
        stat_data = [stat_data;exp_data];
    end
    
    group = zeros(length(stat_data),ncol);
    
    count = 1;
    for j=1:nrow
        exp_data = cell2mat(all_data{j});
        for k=1:ncol
            n=length(exp_data);
            group(count:count+n-1,k) = repmat(L18StdOrthoMatrix(j,k),n,1);
        end
        count = count + length(exp_data);
    end
    
%     pval = anova1(stat_data,g2,'off');
    cellGroup = cell(1,ncol);
    for j=[2,3,4]
        cellGroup(:,j) = {group(:,j)};
    end
    [p,table,stats,terms] = anovan(stat_data,cellGroup(2:4),'model',2,'sstype',1,'display','on');
    fprintf('%d\n',p);
end


function [avgDist,stdDist,data] = getAverageDistances(archs)
avgDist = zeros(1,length(archs{1}.dist2PF));
stdDist = zeros(1,length(archs{1}.dist2PF));
data = cell(1,length(archs{1}.dist2PF));

narchs = length(archs);
distances = cell(narchs,1);
for i=1:length(archs{1}.dist2PF)
    n = 0;
    for j=1:narchs
        if ~isempty(archs{j}.dist2PF{i})
            n = n + 1;
            distances{n} =  archs{j}.dist2PF{i};
        end
    end
    distances = distances(1:n);
    avgDist(i) = mean(cell2mat(distances));
    stdDist(i) = std(cell2mat(distances));
    data{i} = distances;
end

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

function nSat = satellitesPerPlane(bitStringKey)
%this function looks at the bitstring built from dist_to_parteofront() and
%returns number of satellites per plane
bitString = str2num(bitStringKey);
nSat = bitString(1);