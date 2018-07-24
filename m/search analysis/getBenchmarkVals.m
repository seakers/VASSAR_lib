function [vals,out] = getBenchmarkVals(path,indicator)
%plots MOEA/D, MOEA/D-DRA, FRRMAB, eMOEA on one figure for all UF 1-10
%problems. problemm name should be like 'UF11' with no underscores.
%indicator should be something like 'HV' to define which indicator to plot.
%returns the indicator valsues for each benchmark for specified indicator
%and the labels of the names of each benchmark algorithm

% path2benchmark = '/Users/nozomihitomi/Dropbox/MOHEA/Benchmarks';
path2benchmark = strcat(path,filesep,'Benchmarks');
benchmark_names = {'EpsilonMOEA','Random'};

% benchmark_names = {'best1opMOEAD','RandomMOEAD'};
vals = cell(length(benchmark_names),1);
out = benchmark_names;

for i=1:length(benchmark_names)
    %string names together to load m file containing results
    algorithm = benchmark_names{i};
    
    if strcmp(algorithm,'best1opeMOEA') || strcmp(algorithm,'best1opMOEAD')
        file = dir(strcat(path2benchmark,'*'));
        mfilename = strcat(path2benchmark,filesep,algorithm,filesep,file(1).name);
        str = strsplit(file(1).name,'.');
        str = strsplit(str{1},'+');
        str = strsplit(str{1},'_');
        if strcmp(algorithm,'best1opeMOEA')
            str{end-1} = '\epsilonMOEA*';
        elseif strcmp(algorithm,'best1opMOEAD')
            str{end-1} = 'DRA*';
        end
    elseif strcmp(algorithm,'EpsilonMOEA')
        mfilename = strcat(path2benchmark,filesep,algorithm,'.mat');
    else
        mfilename = strcat(path2benchmark,filesep,algorithm,'.mat');
    end
    load(mfilename)
    %assumes that mat file was saved with variable results containing all
    %MOEA indicator metrics
    vals{i} = getfield(res,indicator);
end
