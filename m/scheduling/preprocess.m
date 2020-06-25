function [] = preprocess( )

%% Constants.

xlsFile = 'preprocess_INT.xlsx';

%% Import data.

[i2m i2m_labels] = xlsread(xlsFile, 'i2m');
[m2o m2o_labels] = xlsread(xlsFile, 'm2o');
[p2o p2o_labels] = xlsread(xlsFile, 'p2o');
[M2i M2i_labels] = xlsread(xlsFile, 'M2i');

% Later additions
[p2oN  p2oN_labels]          = xlsread(xlsFile, 'p2oNormalized');

% To be used in main processing.
[iCost iCost_labels]         = xlsread(xlsFile, 'iCost');
[iBudget iBudget_labels]     = xlsread(xlsFile, 'iBudget'); %1st Row is 'High', 2nd row is 'Med', 3rd Row is 'Low'
[iTRL  iTRL_labels]          = xlsread(xlsFile, 'iTRL');
[pScores pScores_labels]     = xlsread(xlsFile, 'panelScores');
[pDepRates pDepRates_labels] = xlsread(xlsFile, 'panelDepRates');
[cont cont_labels]           = xlsread(xlsFile, 'Continuity');
[Lifetime Lifetime_labels]   = xlsread(xlsFile, 'LifeTime');
[startTime startTime_labels] = xlsread(xlsFile, 'StartTime');

% Internationals
[int_miss_dates int_miss_labels] = xlsread(xlsFile, 'int_dates');
int_numMission = size(int_miss_dates,1);
int_launchdates = int_miss_dates(:,1);
int_EOLdates = int_miss_dates(:,2);
int_MissionNames = int_miss_labels(2:5,1);
[int_i2m int_instrum_labels] = xlsread(xlsFile, 'int_i2m');
[int_M2i useless_labels] = xlsread(xlsFile, 'int_M2i');
[int_correls useless_labels] = xlsread(xlsFile, 'int_correl');

% Transform it to get rid of NaNs.
i2m(isnan(i2m)) = 0;
m2o(isnan(m2o)) = 0;
p2o(isnan(p2o)) = 0;
M2i(isnan(M2i)) = 0;

p2oN(isnan(p2oN)) = 0;
cont(isnan(cont)) = 0;

int_i2m(isnan(int_i2m)) = 0;
% iTRL_labels = iTRL_labels(1,2:end);%No longer needed, see instruments

%% Calculate dimensions of the various matrices and sizes of arrays for
% future use.

dimsI2m = size(i2m);
dimsM2o = size(m2o);
dimsP2o = size(p2o);
dimsM2i = size(M2i);
dimsP2oN = size(p2oN);

dims_intI2m = size(int_i2m);% Daniel

numPanels       = dimsP2o(2);
numInstruments  = dimsI2m(2);
numObjectives   = dimsM2o(1);
numMeasurements = dimsM2o(2);
numMissions = dimsM2i(2);

num_intInstruments  = dims_intI2m(2); % Daniel
Budget_level = 1; % High = 1, Medium = 2, Low = 3

%% Extract labels for final results
panels = p2o_labels(1,:);
panels = panels(1, 2:end);
panels_col = panels';
objectives = m2o_labels(2:end,1);
instruments = i2m_labels(1,2:end);
measurements = i2m_labels(2:end,1);
missions = M2i_labels(1,2:end);

%% Matrix Calcs
% All values in i2m are on a scale of 0 to 4.  Scale all values to be from
% 0 to 1 by dividing by 4.
i2m = i2m ./ 4;

% Instruments2Objectives matrix is the cross product of the two tables Theo
% created.

i2o = m2o * i2m;

%% More detailed computations.

sumM2o = sum(m2o,2);
for i = 1:numInstruments
    for j = 1:numObjectives
        scaledSumI2o(j,i) = i2o(j, i) ./ sumM2o(j);
    end
end
scaledSumI2o(isnan(scaledSumI2o)) = 0;

% Daniel: internationals
int_i2m = int_i2m ./ 4;
int_i2o = m2o * int_i2m;
scaledSum_intI2o = zeros(numObjectives,num_intInstruments);
for i = 1:num_intInstruments
    for j = 1:numObjectives
        scaledSum_intI2o(j,i) = int_i2o(j, i) ./ sumM2o(j);
    end
end
scaledSum_intI2o(isnan(scaledSum_intI2o)) = 0;


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

%% compute the end result: p2i

for i = 1:numInstruments
    iCol = scaledSumI2o(:,i);
    for p = 1:numPanels
        pCol = scaledP2o(:,p);
        p2i(p,i) = sum(iCol .* pCol);
    end
end

% [m numMissions]=size(p2i);

% surf(p2i)
%% Translate p2i into p2M to use Missions
p2M = p2i * M2i;

%% Calculate modified values accounting for international missions
int_p2i = zeros(numPanels,num_intInstruments);

for i = 1:num_intInstruments
    iCol = scaledSum_intI2o(:,i);
    for p = 1:numPanels
        pCol = scaledP2o(:,p);
        int_p2i(p,i) = sum(iCol .* pCol);
    end
end

int_p2M = int_p2i * int_M2i;

%% Save results to a MAT file for Dan's GA

save gaInputs.mat p2M M2i i2m pDepRates iCost iBudget iTRL pScores cont ...
                   startTime Lifetime numMissions numInstruments numMeasurements numPanels...
                   Budget_level panels instruments measurements missions cont_labels...
                   int_numMission int_launchdates int_EOLdates int_MissionNames int_i2m...
                   int_M2i int_correls int_p2M

      
%% Write new tables to Excel file
% xlswrite(xlsfile,M,sheet, range) , Labels should start at 'B1' or 'A2',
% Data should start at 'B2'

xlswrite(xlsFile,objectives,'m2oSum','A2')
xlswrite(xlsFile,sumM2o,'m2oSum','B2')

xlswrite(xlsFile,i2m_labels,'i2mN','A1')
xlswrite(xlsFile,i2m,'i2mN','B2')

xlswrite(xlsFile,instruments,'i2o','B1')
xlswrite(xlsFile,objectives,'i2o','A2')
xlswrite(xlsFile,i2o,'i2o','B2')

xlswrite(xlsFile,instruments,'i2oSum','B1')
xlswrite(xlsFile,objectives,'i2oSum','A2')
xlswrite(xlsFile,scaledSumI2o,'i2oSum','B2')

xlswrite(xlsFile,instruments,'p2i','B1')
xlswrite(xlsFile,panels_col,'p2i','A2')
xlswrite(xlsFile,p2i,'p2i','B2')

xlswrite(xlsFile,missions,'p2M','B1')
xlswrite(xlsFile,panels_col,'p2M','A2')
xlswrite(xlsFile,p2M,'p2M','B2')
%% transform p2i into RSF for input to Moolloy
% 
% counter = 1;
% for p = 1:numPanels
%     panel = char(panels(p));
%     for i = 1:numInstruments
%         instrument = char(['i' int2str(i)]); % TODO: lookup instrument name
%         utility = num2str(round(1000 * p2i(p,i)));
%         rsf(counter) = cellstr(sprintf('%s %s %s', panel, instrument, utility));
%         counter = counter + 1;
%     end
% end
% 
% rsf = transpose(rsf);
% rsf;
% 
% fid = fopen('preprocess.rsf', 'wt');
% for r = 1:(counter-1)
%     fprintf(fid, '%s\n', char(rsf(r)));
% end
% fclose(fid);
end
