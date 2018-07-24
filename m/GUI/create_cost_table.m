function data = create_cost_table

    global zeResult;
    global r
    c = r.getGlobalContext;
    
    data = cell(100,10);

    % Cost model
    % [num,txt,raw] = xlsread(params.master_xls,'Output');
    % headers = txt(:,1);
    % Cost model
    % Ground segment cost
    data(1,1:10) = {'Mission','Payload cost per Sat','Bus Size','Bus cost per Sat','Per Sat cost','Num sat', 'Total plane cost','Launch cost','Replenishment', 'Total'};

    missions = zeResult.getCost_facts;
    n = 2;

    for i = 1:missions.size
        mission = missions.get(i-1);
        numSat = mission.getSlotValue('num-of-sats-per-plane#').floatValue(c);
        replenish = mission.getSlotValue('replenishment-factor#').floatValue(c);
        numPlanes = mission.getSlotValue('num-of-planes#').floatValue(c);
        
        data(n,1) = {char(mission.getSlotValue('orbit-string').stringValue(c))};
        data(n,2) = {mission.getSlotValue('payload-cost#').floatValue(c)/(numSat*replenish*numPlanes)};
        data(n,3) = {char(mission.getSlotValue('bus').stringValue(c))};
        data(n,4) = {mission.getSlotValue('bus-cost#').floatValue(c)/(numSat*replenish*numPlanes)};
        data(n,5) = {(data{n,2}+data{n,4})};
        data(n,6) = {numSat};
        data(n,7) = {(data{n,2}+data{n,4})*numSat};
        data(n,8) = {mission.getSlotValue('launch-cost#').floatValue(c)};
        data(n,9) = {replenish};
        data(n,10) = {mission.getSlotValue('mission-cost#').floatValue(c)};
        n=n+1;
    end
    
    data(n,1) = {'Total Cost'};
    data(n,10)={sum(cell2mat(data(2:end,10)))};
    
end