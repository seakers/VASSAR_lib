clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constants.

xlsFile = 'preprocess.xls';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import data.

[i2m i2m_labels] = xlsread(xlsFile, 'i2m');
[m2o m2o_labels] = xlsread(xlsFile, 'm2o');
[p2o p2o_labels] = xlsread(xlsFile, 'p2o');

% Later additions
[p2oN  p2oN_labels]          = xlsread(xlsFile, 'p2oNormalized');

% To be used in main processing.
[iCost iCost_labels]         = xlsread(xlsFile, 'iCost');
[iTRL  iTRL_labels]          = xlsread(xlsFile, 'iTRL');
[pScores pScores_labels]     = xlsread(xlsFile, 'panelScores');
[pDepRates pDepRates_labels] = xlsread(xlsFile, 'panelDepRates');
[cont cont_labels]           = xlsread(xlsFile, 'Continuity');
[other other_labels]         = xlsread(xlsFile, 'Other');

%  [i2m i2m_labels] = xlsread(xlsFile, 'i2m_test');
%  [m2o m2o_labels] = xlsread(xlsFile, 'm2o_test');
%  [p2o p2o_labels] = xlsread(xlsFile, 'p2o_test');

% Transform it to get rid of NaNs.
i2m(isnan(i2m)) = 0;
m2o(isnan(m2o)) = 0;
p2o(isnan(p2o)) = 0;

p2oN(isnan(p2oN)) = 0;
cont(isnan(cont)) = 0;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate dimensions of the various matrices and sizes of arrays for
% future use.

dimsI2m = size(i2m);
dimsM2o = size(m2o);
dimsP2o = size(p2o);

dimsP2oN = size(p2oN);

numPanels       = dimsP2o(2);
numInstruments  = dimsI2m(2);
numObjectives   = dimsM2o(1);
numMeasurements = dimsM2o(2);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% extract labels for final results
panels = p2o_labels(1,:);
panels = panels(1, 2:7);  % TODO: the 7 here should be computed ...
instruments = i2m_labels(1,:); % TODO: this isn't really working ...


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% All values in i2m are on a scale of 0 to 4.  Scale all values to be from
% 0 to 1 by dividing by 4.
i2m = i2m ./ 4;

% Instruments2Objectives matrix is the cross product of the two tables Theo
% created.

i2o = m2o * i2m;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% More detailed computations.

sumM2o = sum(m2o,2)
for i = 1:numInstruments
    for j = 1:numObjectives
        scaledSumI2o(j,i) = i2o(j, i) ./ sumM2o(j);
    end
end
scaledSumI2o(isnan(scaledSumI2o)) = 0;

% This was Derek and Dan's hack to scale p2o.  After discussion with Theo,
% we decided to use the numbers he has hard-coded into the spreadsheet
% because he had some meaningful way of generating these.  See below.
% for i = 1:numPanels
%     p2o(:,i);
%     tmp1 = p2o(:,i);
%     maxtmp1 = max(tmp1);
%     tmp2 = maxtmp1 ./ tmp1;
%     tmp2(isinf(tmp2)) = 0;
%     sumtmp2 = sum(tmp2);
%     tmp3 = tmp2 ./ sumtmp2;
%     for j = 1:numObjectives
%         scaledP2o(j,i) = tmp3(j);
%     end
% end
% 
% scaledP2o;



% Use hardcoded values Theo put in file instead of Derek and Dan's hack.
scaledP2o = p2oN;
scaledP2o;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the end result: p2i

for i = 1:numInstruments
    iCol = scaledSumI2o(:,i);
    for p = 1:numPanels
        pCol = scaledP2o(:,p);
        p2i(p,i) = sum(iCol .* pCol);
    end
end
 
p2i

% surf(p2i)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get a few constants from the spreadsheet

annualBudget    = other(1);
startTime       = other(2);
missionLifespan = other(3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save results to a MAT file for Dan's GA

save gaInputs.mat p2i pDepRates iCost iTRL pScores cont ...
                  annualBudget startTime missionLifespan

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transform p2i into RSF for input to Moolloy

counter = 1;
for p = 1:numPanels
    panel = char(panels(p));
    for i = 1:numInstruments
        instrument = char(['i' int2str(i)]); % TODO: lookup instrument name
        utility = num2str(round(1000 * p2i(p,i)));
        rsf(counter) = cellstr(sprintf('%s %s %s', panel, instrument, utility));
        counter = counter + 1;
    end
end

rsf = transpose(rsf);
rsf

fid = fopen('preprocess.rsf', 'wt');
for r = 1:(counter-1)
    fprintf(fid, '%s\n', char(rsf(r)));
end
fclose(fid);

