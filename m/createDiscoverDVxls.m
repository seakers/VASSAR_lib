function createDiscoverDVxls

resMngr = rbsa.eoss.ResultManager.getInstance();
currentDir = cd;

%open all results files that need to analyzed
files = cell(1);
paths = cell(1);
[FileName,PathName,~] = uigetfile( './*.rs*' );
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
    [FileName,PathName,~] = uigetfile( './*.rs*','MultiSelect','off');
    files{b+1} = FileName;
    paths{b+1} = PathName;
end

%return to original directory
cd(currentDir);

%prompts for the save path and filename 

numFiles = length(files);
for i=1:numFiles
    %load file
    resCol = resMngr.loadResultCollectionFromFile( [paths{i} files{i}] );
    results = resCol.getResults;
    
    %gather the data from the population
    %don't count ref archs
    narch = results.size;
    sci = zeros(narch,1);
    cost = zeros(narch,1);
    features = zeros(narch,11);
    for j = 1:narch
        sci(j) = results.get(j-1).getScience;
        cost(j) = results.get(j-1).getCost;
        arch = results.get(j-1).getArch;
        feat = zeros(1,11);
        
        bitString = double(arch.getBitString)';       
        numSat = arch.getNsats;
        key = mat2str([numSat,bitString]);
        
        
        feat(1) = numSat;
        if hasGEO(key)
            feat(2) = 1;
        end
        if hasATMS(key)
            feat(3) = 1;
        end
        if has50(key)
            feat(4) = 1;
        end
        if has118(key)
            feat(5) = 1;
        end
        if has183(key)
            feat(6) = 1;
        end
        if inGEO(key)
            feat(7) = 1;
        end
        if in600ISS(key)
            feat(8) = 1;
        end
        if in600SSO(key)
            feat(9) = 1;
        end
        if in800AM(key)
            feat(10) = 1;
        end
        if in800PM(key)
            feat(11) = 1;
        end
        
        features(j,:) = feat;
    end
    
    xlswrite(strcat(pwd,'\Exp',num2str(i),'.xls'),{'sci','cost','numSat','hasGEO','hasATMS'...
        'has50','has118','has183','inGEO','in600ISS','in600SSO','in800AM','in800PM'});
    xlswrite(strcat(pwd,'\Exp',num2str(i),'.xls'),[sci,cost,features],1,'A2');
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
