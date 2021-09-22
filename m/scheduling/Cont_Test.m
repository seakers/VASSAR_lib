load gaInputs.mat

ordering = [1:1:numMissions];

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
    
     %% Data Continuity
    % Want to check to see if measurement is required and then check dates
    % to see if there is a gap. 7th Utility will be number of years there
    % is no data
    Data_Cont_Count = 0;
    for i=1:numMissions
        miss = ordering(i);%Mission Number
        instru = 0; %Reset instrument and measurement matrices
        meas = 0;
        k=1;%Counter for instrument on a given mission
        
        for j=1:numInstruments %Get Instruments on a Mission
            if M2i(j,miss) == 1
                instru(k) = j;
                k=k+1;
            end
        end
        
        for ii = 1:length(instru)%Get Measurements assoc. with Instrument on given Mission
            instru_data = instru(ii);
            k=1;
            for l=1:numMeasurements 
                if i2m(l,instru_data) > 0
                    meas(k,ii) = l;
                    k=k+1;
                end
            end
        end
        [m,n]=size(meas);
        for ll = 1:n%If Measurement is cont then check launch date to cont date
            for kk=1:m
               if  cont(meas(kk,ll),1) > 0
                    if launchDate(miss) > cont(meas(kk,ll),2)
                        Data_Cont_Count = Data_Cont_Count + i2m(meas(kk,ll),instru(ll)) * cont(meas(kk,ll),1);
                        cont(meas(kk,ll),2) = launchDate(miss) + Lifetime(miss);
                    elseif 0 < cont(meas(kk,ll),2) - launchDate(miss) < Lifetime(miss)
                        cont(meas(kk,ll),2) = launchDate(miss) + Lifetime(miss);
                    end
               end
            end
        end
        
    end