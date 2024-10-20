function [] = Results( )
%Results just combines fval, which is the value of each schedule for each
%panel, with x, which is the schedule and launch date for each instrument
%   the result can then be copied into Excel

load results_intern.mat
load gaInputs.mat
xlsx = 'preprocess_INT.xlsx';
Result_name = 'Results1';
Top_name = 'Top5_1';
Cont_name = 'Continuity1';
Top_Fig = 'Top5_DS1.fig';
Rank_Fig = 'Rank_DS_1.fig';
Top_Bmp = 'Top5_DS1.bmp';
Rank_Bmp = 'Rank_DS_1.bmp';
%Change the file save name manually

[m,n]=size(fval);
%% Take fval and x and combine them into single matrix
%Transform x from order of instruments to position of each
%instrument
for i=1:length(x) %The first (ordering) is to unpack x into the ordering used by the getUtilities.m so that similar techniques can be applied.
    z=x{i,1};
    for j=1:length(z)
       x3(i,j) = z(j); 
    end
end
ordering = x3; % Contains the ordering of miss/instru
[mm,nn] = size(ordering);
position = zeros(mm,nn);
for i=1:mm % The second (position) is to transform from an ordering to the position of each miss/instru
%     z=x{i,1};
    for j= 1:nn
       position(i,ordering(i,j)) = j; 
    end
end

results2=zeros(mm,nn+7);

%results2 unpacks position to get a matrix with the size of results3 with zeros
%where the panel scores will go
for i=1:mm
    for j=1:nn
    k=j+7;
    results2(i,k) = position(i,j);
    end
end

results = zeros(size(results2));

%results fills in the panel scores from fval
for i=1:m
    for j=1:n
    results(i,j) = fval(i,j);
    end
end

%resutls3 just combines the two above matrices
results3 = results + results2;
[o,p]=size(results3);
%% Get sum of each fval row, which I assume is the value of that schedule
for l=1:m
   PSum(l,1)=-sum(fval(l,1:6)); 
end

%% Find the 5 highest valued schedules
% Sorts through the Panel Sums from fval to get Top 5
PSum5 = zeros(5,p-3);

for g=1:length(PSum)
    if PSum(g)>PSum5(1,2)
        PSum5(5,:)=PSum5(4,:);
        PSum5(4,:)=PSum5(3,:);
        PSum5(3,:)=PSum5(2,:);
        PSum5(2,:)=PSum5(1,:);
        PSum5(1,2:4)=[PSum(g),results3(g,7),g];
    elseif PSum(g)>PSum5(2,2)
        PSum5(5,:)=PSum5(4,:);
        PSum5(4,:)=PSum5(3,:);
        PSum5(3,:)=PSum5(2,:);
        PSum5(2,2:4)=[PSum(g),results3(g,7),g];
    elseif PSum(g)>PSum5(3,2)
        PSum5(5,:)=PSum5(4,:);
        PSum5(4,:)=PSum5(3,:);
        PSum5(3,2:4)=[PSum(g),results3(g,7),g];
    elseif PSum(g)>PSum5(4,2)
        PSum5(5,:)=PSum5(4,:);
        PSum5(4,2:4)=[PSum(g),results3(g,7),g];
    elseif PSum(g)>PSum5(4,2)
        PSum5(5,2:4)=[PSum(g),results3(g,7),g];
    else
    end
    
end
PSum5(:,1)=[1;2;3;4;5];

%Fill in the Top 5 with the positions of those missions that make up that
%architecture
[oo,pp]=size(PSum5);
for h=1:oo
    PSum5(h,5:end) = results3(PSum5(h,4),8:end);
%     e=8;
%     for f=5:pp
%             PSum5(h,f)=results3(PSum5(h,4),e);
%             e=e+1;
%     end
end

%% Sort all the results, mainly for plotting, but could do a number of
% things with this
% Ranked = zeros
Ranked_PS = sortrows(PSum,-1); %Ranked(:,2); %Just the ranked Total Panel Scores

%% Launch Dates
%Recalculate launch dates for infomation sake
LaunchDates = zeros(2*oo,pp);
launchDate = zeros(1, numMissions);
    for jj = 2:2:2*oo %Skip each Psum5 row and fill in every other
        LaunchDates((jj-1),:) = PSum5((jj/2),:);
        arch_num = PSum5((jj/2),4);
        tmpDate    = startTime;
        for ll = 1:numMissions
            miss = ordering(arch_num,ll);
            cost = iCost(miss);
            year_up = ceil(tmpDate)-startTime+1; % number of years from start, rounded up
            budget = iBudget(Budget_level,year_up); % Finds the budget for the next year, if a project doesn't take a full year, this will repeat budgets
            tmpDate = ceil(tmpDate) + (cost / budget);
            launchDate(miss) = tmpDate;
        end
        LaunchDates(jj,5:end) = launchDate; 
    end
 %% Data Continuity
% Want to check to see if measurement is required and then check dates
% to see if there is a gap. 7th Utility will be number of years there
% is no data
arch_num = PSum5(1,4);
launchDate = LaunchDates(2,5:end);
Data_Cont_Count = 0; 
data_gap = zeros(numMeasurements,2);
cont_new = cont;
for i=1:numMissions
    miss = ordering(arch_num,i);%Mission Number
    instru = 0;
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
           if  meas(kk,ll) > 0 && cont_new(meas(kk,ll),1) > 0
                if launchDate(miss)>cont_new(meas(kk,ll),2)
                    data_gap(meas(kk,ll),1) = data_gap(meas(kk,ll),1) + launchDate(miss) - cont_new(meas(kk,ll),2);
                    Data_Cont_Count = Data_Cont_Count + i2m(meas(kk,ll),instru(ll)) * cont_new(meas(kk,ll),1);
                    cont_new(meas(kk,ll),2) = launchDate(miss) + Lifetime(miss);
                elseif 0 < cont_new(meas(kk,ll),2) - launchDate(miss) < Lifetime(miss)
                    data_gap(meas(kk,ll),1) = data_gap(meas(kk,ll),1) + cont_new(meas(kk,ll),2) - launchDate(miss);
                    cont_new(meas(kk,ll),2) = launchDate(miss) + Lifetime(miss);
                end
           end
        end
    end

end
cont_rd = ceil(cont_new(:,2));
for i=1:numMeasurements
data_gap(i,2) = max(cont_new(:,2)) - cont_new(i,2) + data_gap(i,1);
end
%% Attempt at Plotting the results
%Going through PSum5 to get y positions for each miss/instru
%Have to set the symbol for each miss/instru
leg_sym = {'+k', '+b', '+m', '+r', 'ok', 'om', 'ob', 'or', '*k', '*m', '*b', '*r',...
    '.k', 'xk', 'sk', 'dk', '^k', '.r', 'xr', 'sr', 'dr', '^r', '.m', 'xm', 'sm', 'dm',...
    '^m', '.b', 'xb', 'sb', 'db', '^b', '+y', 'oy', '*y', '.y', 'xy', 'sy', 'dy', '^y'};

for kk=1:length(missions)
    leg(kk,:) = [missions(kk), leg_sym(kk)];%This is coming out as a 2X38 Cell Array
end
    
figure('Name', 'Top 5 Schedules', 'Position', [50, 50, 1500, 1000])
for ii=1:(nn)
%     leg_n = leg(2,ii);
%     plot(PSum5(:,1), PSum5(:,(ii+3)),leg{2,ii})
    plot(PSum5(:,1), [LaunchDates(2,(ii+3)); LaunchDates(4,(ii+3)); LaunchDates(6,(ii+3)); LaunchDates(8,(ii+3)); LaunchDates(10,(ii+3))],leg{ii,2})
%     legend(leg{1,ii})
    hold on
end
% Label and set axes
title('Top 5 Schedules')
xlabel('Position: 1-5')
ylabel('Launch Position')
axis([0 6 startTime (max(LaunchDates(2,4:end))+2)])

for i = 1:numMissions
    leg2{1,i} = leg{i,1};
    
end
legend(leg2)

saveas(gcf,Top_Fig)
saveas(gcf,Top_Bmp)
%% Plotting All Schedules
% Want scatter plot of all the schedules to see where the Top 5 lie
figure('Name', 'Ranked Schedules', 'Position', [50, 50, 1500, 1000])
subplot(1,2,1)
plot([1:1:length(Ranked_PS)], Ranked_PS,'+')

title('Ranked Total Panel Scores')
xlabel('Rank')
ylabel('Discounted Total Panel Score')

subplot(1,2,2)
plot([1:1:10], Ranked_PS(1:10), 'ok')
title('Top 10 Total Panel Scores')
xlabel('Rank')
ylabel('Discounted Total Panel Score')

saveas(gcf,Rank_Fig)
saveas(gcf,Rank_Bmp)
%% Write resutls to Excel File

numSchedules = [1:1:length(PSum)]';
Schnum = {'Schedule #'};
PanSum = {'Panel Sum'};
TotPan = {'Total Panel Sum'};
RK = {'Rank'};
Cont_score = {'Data Continuity Score'};

xlswrite(xlsx,panels,Result_name,'C1')
xlswrite(xlsx,Schnum,Result_name,'A1')
xlswrite(xlsx,PanSum,Result_name,'B1')
xlswrite(xlsx,Cont_score,Result_name,'I1')
xlswrite(xlsx,missions,Result_name,'J1')
xlswrite(xlsx,numSchedules,Result_name,'A2')
xlswrite(xlsx,PSum,Result_name,'B2')
xlswrite(xlsx,results3,Result_name,'C2')

xlswrite(xlsx,Cont_score,Top_name,'C1')
xlswrite(xlsx,RK,Top_name,'A1')
xlswrite(xlsx,TotPan,Top_name,'B1')
xlswrite(xlsx,Schnum,Top_name,'D1')
xlswrite(xlsx,missions,Top_name,'E1')
xlswrite(xlsx,LaunchDates,Top_name,'A2')

xlswrite(xlsx,cont_labels,Cont_name,'A1')
xlswrite(xlsx,cont,Cont_name,'B2')
xlswrite(xlsx,{'New Dates'},Cont_name,'D1')
xlswrite(xlsx,{'Round up'},Cont_name,'E1')
xlswrite(xlsx,{'Total Gap Years'},Cont_name,'F1')
xlswrite(xlsx,{'Gap Years plus Time till End'},Cont_name,'G1')
xlswrite(xlsx,cont_new(:,2),Cont_name,'D2')
xlswrite(xlsx,cont_rd,Cont_name,'E2')
xlswrite(xlsx,data_gap,Cont_name,'F2')
%% Save the results for later use
save Results_DS1.mat results3 PSum PSum5 LaunchDates Ranked_PS data_gap
end

