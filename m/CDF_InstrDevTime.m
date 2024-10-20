function [x,cdf_dev_time] = CDF_InstrDevTime(IDE,TRL)
%% Returns the CDFs of every instrument defined with the two arrays IDE and
%% TRL.
N_INSTR = length(IDE);

%% Assumptions
unknown = find(IDE==0); % Indexes of instruments for which IDE unknown
IDE(unknown) = 8.187*exp(-.157*TRL(unknown));% This exponential is fit so that it gives a min DT of 2 years for TRL = 9 and 7 years for TRL = 1.
RSS_TRL = 8.29*exp(-0.56.*[1:9]);% Dubos and Saleh.
MAX = [3 2.8 2.6 2.4 2.2 2.0 1.8 1.6 1.4];
MAX_DEV_TIME = IDE.*(1+RSS_TRL(TRL)).*MAX(TRL); % This equation provides a worst case DT = 21 years for TRL = 1 and 2.8 years for TRL = 9

% RSS_TRL = .275+.025*[1:9];% This curve is fit to provide a mode centered at 70% for TRL = 1 () and 50% for TRL = 9.
%% Loop
cdf_dev_time = zeros(1000,N_INSTR);
x = zeros(1000,N_INSTR);

for i = 1:N_INSTR
    min = IDE(i);
    max = MAX_DEV_TIME(i);
%     mode = RSS_TRL(TRL(i))*min + (1-RSS_TRL(TRL(i)))*max;
    mode = min*(1 + RSS_TRL(TRL(i)));
    mean = (min + 4*mode + max)/6;
    stdev = (max - min)/6;

    a = ((mean - min)/(max-min))*((mean - min)*(max - mean)/stdev^2-1);
    b= ((max - mean)/(mean - min))*a;
    
    step = (max-min)/999;
    x(:,i) = min:step:max;
    cdf_dev_time(:,i) = betainc(((x(:,i)-min)./(max-min)),a,b);
end
 return