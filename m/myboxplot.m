function myboxplot(data,labels,ylab,filename)
    fontSize = 18;
    rotation = 45;
    tickLabelStr = labels;
    % generate data
    final_res = data;
    
    % group boxes
    width = 0.5;
    sh = 0.1; 
    
    pos = [1+sh 2-sh 3+sh];
    wid = width * ones(1,length(pos));
    
    % boxplot
    figure
%     boxplot(final_res, 'notch', 'on', ...
%             'positions', pos,...
%             'widths', wid) 
    boxplot(final_res, labels) 
    % label, change fontsize
    % y-axis
    set(gca, 'FontSize', fontSize)
    ylabel(ylab, 'FontSize', fontSize)
    
    %x-labels
    text_h = findobj(gca, 'Type', 'text');
    
    
    for cnt = 1:length(text_h)
        set(text_h(cnt),    'FontSize', fontSize,...
                            'Rotation', rotation, ...
                            'String', tickLabelStr{length(tickLabelStr)-cnt+1}, ...
                            'HorizontalAlignment', 'right','VerticalAlignment', 'cap')
    end
    
    % 'VerticalAlignment', 'cap', ...
    
    % smaller box for axes, in order to un-hide the labels
    squeeze = 0.4;
    left = 0.04;
    right = 1;
    bottom = squeeze;
    top = 1-squeeze;
    set(gca, 'OuterPosition', [left bottom right top])
    
    grid on;
    print('-dpng',[filename '.png']);

%         
%     % remove outliers
%     hout = findobj(gca,'tag','Outliers');
%     for out_cnt = 1 : length(hout)
%         set(hout(out_cnt), 'Visible', 'off')
%     end
end
