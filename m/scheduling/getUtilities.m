function utilities = getUtilities(ordering) 
% This is the Fitness Function ...
%TODO:  THEO SAID SOMETHING ABOUT 1-4 GOING TO .1 TO .9.
    %Combine panel utilities into a single number weighted by panel weights
    % Add in other metrics to the utilites, so that some are not good
    %% Constants and variables.

    % Get array of mission orderings out of the cell array.
    ordering = ordering{1};
    
    % Load mat file.  This contains variables stored off from the
    % preprocessing operation that also created Derek's Mooloy inputs.
    load gaInputs.mat
 
    % TODO: It may be inefficient to load the mat file every time.  Consider
    % profiling it to see if there is a better way to get preprocessed
    % variables in the namespace.
    
    %% Validate that the ordering array is correctly formed.
    
    % Comment out while GA is being run.  Might be waste of time.
    % assert(length(ordering) == numMissions);
    
    % TODO: others including each num represented once.
    
    %% Validate that the ordering array is correctly formed.

    
    % Get dates for each mission based on the ordering and the cost.
    %startDate  = zeros(numMissions,1);
    launchDate = zeros(numMissions,1);
    tmpDate    = startTime;
    for i = 1:numMissions
        miss = ordering(i);
        cost = iCost(miss);
        year_up = ceil(tmpDate)-startTime+1;% number of years from start, rounded up
        budget = iBudget(Budget_level,year_up);% Finds the budget for the next year, if a project doesn't take a full year, this will repeat budgets
        tmpDate = tmpDate + (cost / budget); %Adds the time to launch based on budget to the time line
        launchDate(miss) = tmpDate;
    end
   
        %% Daniel: Take into account international missions
    % For each domestic mission, if it coincides in time with a higly
    % correlated international mission then its value is decreased.

    [row_correl col_correl] = find(int_correls>0); %  [row_correl col_correl] contains the coordinates of all the positive correlations
    num_coinc = length(row_correl);
    p2M_modified = p2M;
    PENALTY = 0.80;
    for kk = 1:num_coinc
        if launchDate(row_correl(kk)) >= int_launchdates(col_correl(kk)) && launchDate(row_correl(kk)) <= int_EOLdates(col_correl(kk))
            
            tmp = p2M_modified(:,row_correl(kk));% tmp contains the six original values of the domestic mission to the panel
            indexes = find(int_p2M(:,col_correl(kk))>0);
            tmp(indexes) = PENALTY.*tmp(indexes); % The value of the domestic mission to each panel to which the international mission provides value is multiplied by PENALTY < 1 
            p2M_modified(:,row_correl(kk)) = tmp;
        end
    end
    
    
    %% Use launch dates to discount utility of each mission for each panel.
    invDepRates = 1 - pDepRates;
    p2MDiscounted = p2M_modified; % Daniel: modified by internationals
    
    
    for i = 1:numMissions
        timeTilLaunch = launchDate(i) - startTime;
        depreciation = invDepRates .^ timeTilLaunch;
        p2MDiscounted(:,i) = p2MDiscounted(:,i) .* depreciation;
    end
     
    
    %% Sum up utilities for each mission to get a total utility for the
    % each panel.
    utilities = sum(p2MDiscounted, 2);
    
    %% GA does minimization.  Turn max into min by operating on negative
    % numbers.
    utilities = utilities .* -1;
    
    %% Weight each sum by Panel weight
    pSum = sum(pScores);
    for k=1:length(pScores)
        utilities(k)=utilities(k)*(pScores(k)/pSum);
    end
    
    %% Check TRL dates match up with launch dates
    % Go through launch dates for the given order and check with TRL dates
    % If any TRL date is violated, turn utilities to zero
    for j=1:numMissions
       if launchDate(j)<iTRL(ordering(j))
           utilities = utilities .* 0;
       end
    end
    
    %% Data Continuity
    % Want to check to see if measurement is required and then check dates
    % to see if there is a gap. 7th Utility will be number of years there
    % is no data
    Data_Cont_Count = 0;
    for i=1:numMissions
        miss = ordering(i);%Mission Number
        k=1;%Counter for instrument on a given mission
        instru = zeros(numInstruments,1);
        for j=1:numInstruments %Get Instruments on a Mission
            if M2i(j,miss) == 1
                instru(k) = j;
                k=k+1;
            end
        end
        instru = instru(1:k-1);
        
        for ii = 1:length(instru)%Get Measurements assoc. with Instrument on given Mission
            instru_data = instru(ii);
            k=1;
            meas = zeros(numMeasurements,1);
            for l=1:numMeasurements 
                if i2m(l,instru_data) > 0
                    meas(k,ii) = l;
                    k=k+1;
                end
            end
            meas = meas(1:k-1);
        end
        [m,n]=size(meas);
        for ll = 1:n%If Measurement is cont then check launch date to cont date
            for kk=1:m
               if  meas(kk,ll) > 0 && cont(meas(kk,ll),1) > 0
                    if launchDate(miss)>cont(meas(kk,ll),2)
                        Data_Cont_Count = Data_Cont_Count + i2m(meas(kk,ll),instru(ll)) * cont(meas(kk,ll),1);
                        cont(meas(kk,ll),2) = launchDate(miss) + Lifetime(miss);
                    elseif 0 < cont(meas(kk,ll),2) - launchDate(miss) < Lifetime(miss)
                        cont(meas(kk,ll),2) = launchDate(miss) + Lifetime(miss);
                    end
               end
            end
        end
        
    end
    
    utilities((numPanels+1)) = Data_Cont_Count;
    
    %% Algorithm wants utilities returned as a row vector rather than a
    % column vector.
    utilities = utilities';
        
end

