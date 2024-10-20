function SCAN_sensitive_plot(src,eventdata,archs,results,inaxis,indexes)
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    xvals = results.(get_plural2(inaxis{1}));
    yvals = results.(get_plural2(inaxis{2}));
    
    [val, i] = min(abs((xvals - xmouse)/xmouse).^2+abs((yvals - ymouse)/ymouse).^2);
    xpoint   = xvals(i);
    ypoint   = yvals(i);
    arch = archs{i};
    fprintf('Arch: %s\n',char(arch.toString));
    fprintf(['Arch = %d, ' inaxis{1} '  = %.2f, ' inaxis{2} ' = %.2f\n'],indexes(i),xvals(i),yvals(i)); 
end