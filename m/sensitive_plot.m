function sensitive_plot(src,eventdata,archs,sciences,costs,utilities,pareto_ranks)
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [val, i] = min(abs((sciences - xmouse)/xmouse).^2+abs((costs - ymouse)/ymouse).^2);
    xpoint   = sciences(i);
    ypoint   = costs(i);
    arch = archs{i};
    fprintf('Arch: %s\n',char(arch));
    fprintf('Arch = %d, utility = %.3f, Science = %.2f, Cost = %.0f, Pareto rank = %d\n',i,utilities(i),sciences(i),costs(i),pareto_ranks(i)); 
end