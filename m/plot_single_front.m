function plot_single_front(results)
    narch = results.size;
    benefits = zeros(narch,1);
    costs = zeros(narch,1);
    archs = cell(narch,1);
    for i = 1:narch
        result = results.get(i-1);
        benefits(i) = result.getScience;
        costs(i) = result.getCost;
        archs{i} = result.getArch;
    end
    plot(benefits, costs,'rd','ButtonDownFcn', {@sensitive_plot,archs,benefits,costs});
    xlabel('Benefit');
    ylabel('Cost');
end

function sensitive_plot(src,eventdata,archs,benefits,costs)
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [~, i] = min(abs((benefits - xmouse)/xmouse).^2+abs((costs - ymouse)/ymouse).^2);
    arch = archs{i};

    fprintf('Arch = %d, Science = %f, Cost = %f, str = %s\n',i,benefits(i),costs(i),char(arch.toString));
    

end