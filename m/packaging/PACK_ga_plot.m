function state = PACK_ga_plot(unused,state,flag,fcn)
fid = fopen('control_matlab.txt','r');
s = fscanf(fid,'%s\n');
fclose(fid);
if strcmp(s(end-3:end),'stop')
    fprintf('Stopping...\n');
    keyboard();
end 
switch flag
    % Plot initialization
    case 'init'
        scores = state.Score;
        plotHandle = plot(scores(:,1),scores(:,2),'*');
        set(plotHandle,'Tag','PACK_ga_plot');

        % Pause for three seconds to view the initial plot
        pause(3);
    case 'iter'
        scores = state.Score;
        plotHandle = findobj(get(gca,'Children'),'Tag',...
                     'PACK_ga_plot');
        set(plotHandle,'Xdata',scores(:,1),'Ydata',scores(:,2));
end
