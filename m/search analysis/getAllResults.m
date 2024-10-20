function [NFE,fHV,ET] = getAllResults(path,selector,creditDef)
%Given a path, the heuristic selector name, credit definition name, and
%problem name this function will get all the results from the given path 
%with files that include the selector name and the credit definition name. 
%
%This function returns the epsilon indicator EI, generational distance GD,
%hyper volume HV, and inverted generational distance as a n x m matrix where n is the number files
%containing the selector name and credit definition name and m is the
%number of values collected per file.

origin = cd(path);
files = dir(strcat('*',selector,'*',creditDef,'*.res'));
cd(origin)
nfiles = length(files);
npts = 817;
NFE = zeros(npts,nfiles);
fHV = zeros(npts,nfiles);
ET = zeros(npts,nfiles);
for i=1:nfiles
    [tnfe,tfHV,tET] = getMOEAIndicators(strcat(path,filesep,files(i).name));
    NFE(:,i) = tnfe(1:npts);
    fHV(:,i) = tfHV(1:npts);
    ET(:,i) = tET(1:npts);
end
end
