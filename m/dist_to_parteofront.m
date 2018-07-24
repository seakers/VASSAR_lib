function [keySet,dist2PFMat] = dist_to_parteofront()

%This function loads the data from multiple results files and outputs the
%bit string of an architecture and its corresponding distance from the
%pareto front. The architecture bit string is formatted as number of
%satellites per plane and then the bit string that represents the
%instruments to orbits assignment. The distance matrix rows are all the unique
%architectures and the columns are for each results file loaded. If there
%is a null value (ie []) then it means that the architecture did not exist
%in the population in that result file.

resMngr = rbsa.eoss.ResultManager.getInstance();
ATE = rbsa.eoss.ArchTradespaceExplorer.getInstance();
currentDir = cd;

%open all results files that need to analyzed
files = cell(1);
paths = cell(1);
[FileName,PathName,FilterIndex] = uigetfile( './*.rs*' );
files{1} = FileName;
paths{1} = PathName;
loadMoreFiles = true;
while loadMoreFiles
    [~,b]=size(files);
    cd(paths{b})
    buttonTitle = strcat('Loaded ',num2str(b),' files');
    button = questdlg('More files to load?',buttonTitle,'Yes','No','Yes');
    if strcmp(button,'No')
        break;
    end
    [FileName,PathName,FilterIndex] = uigetfile( './*.rs*','MultiSelect','off');
    files{b+1} = FileName;
    paths{b+1} = PathName;
end

%return to original directory
cd(currentDir);

numFiles = length(files);
mapArchs = containers.Map; %map will hold unique archs and their distances from the PF for each experiment
for i=1:numFiles
    %load file
    resCol = resMngr.loadResultCollectionFromFile( [paths{i} files{i}] );
    results = resCol.getResults;
    
    %do final nondominated sorting
%     archArray = java.util.ArrayList();
%     for j=0:results.size-1
%         archArray.add(results.get(j).getArch);
%     end
%     so = rbsa.eoss.SearchOptions(500,0,0.5,0.1,0.5,archArray);
%     ATE.setTerm_crit(so);
%     ATE.setCurrent_population(archArray);
%     ATE.selection_NSGA2();
%     results = ATE.getResults;
    
    %gather the data from the population
    %don't count ref archs
    narch = results.size;
    xvals = zeros(narch,1);
    yvals = zeros(narch,1);
    archs = cell(narch,1);
    for j = 1:narch
        xvals(j) = results.get(j-1).getScience;
        yvals(j) = results.get(j-1).getCost;
        archs{j} = results.get(j-1).getArch;
    end
    
    
    %normalize all data so that each metric is in interval [0,1]
    minSci = min(xvals);
    maxSci = max(xvals-minSci);
    minCost = min(yvals);
    maxCost = max(yvals-minCost);
    
    xvals = (xvals-minSci)/maxSci;
    yvals = (yvals-minCost)/maxCost;
    
    %find the architectures on the pareto front
    [x_pareto, y_pareto, inds, ~ ] = pareto_front([xvals yvals] , {'LIB', 'SIB'});
    pf_archs = archs(inds);
    [a,~]=size(pf_archs);
    
    %find unique points on pareto front
    unique_pf_archs = unique([x_pareto,y_pareto],'rows');
    
    %create a cubic spline with the points on the pareto front
    %step size in sci benefit is based on interval of [0,max_sci]
    x_step = linspace(min(unique_pf_archs(:,1)),max(unique_pf_archs(:,1)),10000);
    interpolatedCost = pchip(unique_pf_archs(:,1),unique_pf_archs(:,2),x_step);
    
    %find distance to interpolated pareto front
    %find euclidean distances in all pairs between archs and pareto optimal
    %archs. Find min distnace from among those
    D = pdist2([xvals, yvals],[x_step;interpolatedCost]','euclidean');
    minDist2PF = min(D,[],2);
    
    for j = 1:narch
        clear distances2PF;
        bitString = double(archs{j}.getBitString)';       
        numSat = archs{j}.getNsats;
        key = mat2str([numSat,bitString]);
        %check to see if arch is already in map
        if mapArchs.isKey(key);
            %check to see if arch dist to PF has already been entered (there maybe duplicate archs in a population)
            if length(mapArchs(key))<i
                distances2PF = mapArchs(key);
                distances2PF{1,i} = minDist2PF(j);
                mapArchs(key) = distances2PF;
            end
        %if arch is not in map yet, add it    
        else
            distances2PF{1,i} = minDist2PF(j);
            mapArchs(key) = distances2PF;
        end
    end
end

clear dist2PFMat
%create a matrix from mapArchs
keySet = keys(mapArchs);
numKeys = length(keySet);
archKeys = cell(numKeys,1);
dist2PFMat = cell(numKeys,numFiles);
for i=1:numKeys
    key = keySet{i};
    archKeys{i}=key;
    
    %pad the last column in distances2PF with empty cells if necessary
    %there may not have been a certain arch in the last population. The other
    %populations don't experience this because it is handled in the for loop
    %above
    if length(mapArchs(key))<numFiles
        tmp = mapArchs(key);
        tmp{1,numFiles}={};
        mapArchs(key) = tmp;
    end
    
    dist2PFMat(i,:) = mapArchs(key);
end
