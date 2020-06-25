function [labels,dec1,obj] = loadPopulation(filename)
%this function reads in the output of the labels.csv from the EOSS search.
%The csv file is ordered as label, dec0, dec1, obj0, obj1, where label is
%the label that is assigned to the solution, dec0 is the number of
%satellites per plane, dec1 is the instrument-orbit assignment binary
%vector, obj0 is the normalized, negative scientific benefit, and obj1 is 
%the normalized lifecycle cost
%the first line of the file is skipped over because it contains a header


fid = fopen(filename,'r');
fgetl(fid); %skip header

data = textscan(fid,'%d,%d,%60s,%f,%f');

nsolns = length(data{1});
labels = data{1};
obj = [data{4},data{5}];
dec1 = zeros(nsolns, 60);

for i=1:nsolns
    dec1(i,:) = data{3}{i}-'0';
end

end