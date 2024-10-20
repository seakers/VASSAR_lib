function figure1 = plot_data_continuity_matrix( continuity_matrix )
%plot_data_continuity_matrix
% Plots a data continuity matrix in the following format:
% rows represent measurements from list meas
% columns represent time intervals as described in times
% dcmat(i,j) represents the number of mission/instruments performing
% measurement i over time interval j
global params
MAX = 30;
% get integer matrix
dcmat = cellfun(@size,continuity_matrix);

% get indexes of measurements in list of measurements
important_meas = params.list_of_measurements_for_data_continuity.keySet.iterator;
unsorted_labels = cell(1,params.list_of_measurements_for_data_continuity.size);
unsorted_ids = zeros(params.list_of_measurements_for_data_continuity.size,1);
n = 1;
% init_ids = zeros(params.list_of_measurements_for_data_continuity.size,1);
while important_meas.hasNext()
    id= important_meas.next();
%     init_ids(n) = id;
    tmp = params.list_of_measurements_for_data_continuity.get(id);
    unsorted_labels{n} = tmp(1:min(MAX,length(tmp)));
    unsorted_ids(n) = params.map_of_measurements.get(tmp);
    n = n + 1;
end
[sorted_ids,order] = sort(unsorted_ids);
sorted_labels = unsorted_labels(order);
% sorted_init_ids = init_ids(order);

% Create image
scrsz = get(0,'ScreenSize');
figure1 = figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
axes1 = axes('Parent',figure1,'FontSize',14,'FontName','Arial');

dcmat2 = dcmat(sorted_ids,:);
continuity_matrix2 = continuity_matrix(sorted_ids,:);
dh = imagesc(dcmat2,'Parent',axes1);
ttt = get(axes1,'Position');
set(axes1,'Position',[ttt(1) ttt(2) 0.85*ttt(3) 1*ttt(4)]);
% Create colorbar
colorbar('peer',axes1);
colormap(flipud(gray));
caxis([0 20]);
% axis labels
timeframe = (params.enddate - params.startdate)/params.timestep + 1;
vec = [0:(params.enddate - params.startdate)].*((timeframe - 1)/(params.enddate - params.startdate));
set(axes1,'XTick',vec);
time_labels = params.startdate + (vec).*params.timestep;
set(axes1,'XTickLabel',time_labels);

set(axes1,'YTick',1:params.list_of_measurements_for_data_continuity.size);
% meas_labels = cell(params.map_of_measurements.keySet.toArray);
set(axes1,'YTickLabel',sorted_labels);

set(axes1,'FontSize',10);

% set mouse properties
set(dh, 'ButtonDownFcn', {@mouseclick_callback, axes1, params, dcmat2, timeframe,sorted_labels, continuity_matrix2});
end

%% Mouse click callback
function [] = mouseclick_callback(point_handle, eventdata, axis_handle, params, dcmat2, timeframe,sorted_labels, continuity_matrix2)
    format short
    mouse = get(axis_handle, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    % get data points
    xpoint = round(xmouse);
    ypoint = round(ymouse);
        
%     % find xdata closest to xmouse (could have done ydata/ymouse too)
%     format long E;
%     [val, i] = min(abs(xdata - xmouse).^2+abs(ydata - ymouse).^2);
%     xpoint   = xdata(i);
%     ypoint   = ydata(i);
    
    time = params.startdate + (xpoint-1)*(params.enddate - params.startdate)./(timeframe-1);
    measurement = sorted_labels(ypoint);
    value = dcmat2(ypoint,xpoint);
    
    tmp = continuity_matrix2(ypoint,xpoint);
    missions = tmp{1}.iterator;
    fprintf('*****************************************************************\n');
    fprintf('Measurement " %s " taken in %4.1f by the following %d satellites:\n',measurement{1},round(time*10)/10,value);
    fprintf('*****************************************************************\n');
    
    mTextBox  = uicontrol('style','text','FontSize',6,'HorizontalAlignment','left');
    mTextBox2 = uicontrol('style','text','FontSize',7,'HorizontalAlignment','center');
    mTextBox3 = uicontrol('style','text','FontSize',8,'HorizontalAlignment','center');
    mystring = sprintf('Measurement taken by the following %d satellites:\n',value);
    mystring = sprintf('%s***********************************************\n',mystring);
    meas_string = sprintf('Measurement\n%s',measurement{1});
    date_string = sprintf('Date\n%4.1f',round(time*10)/10);
    while missions.hasNext()
        tt = missions.next();
        mystring = sprintf('%s%s\n',mystring,tt);
        fprintf('%s\n',tt);
    end
    set(mTextBox,'String',mystring);
    set(mTextBox,'Position',[910 80 200 300]);%[x y length height]
    
    set(mTextBox2,'String',meas_string);
    set(mTextBox2,'Position',[910 500 200 30]);%[x y length height]
    
    set(mTextBox3,'String',date_string);
    set(mTextBox3,'Position',[960 600 80 30]);%[x y length height]
    
end

