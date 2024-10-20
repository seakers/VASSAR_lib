function PACK_mouseclick_cost_risk(src,eventdata,archs,sciences,costs,utilities,pareto_ranks,programmatic_risks,fairness_or_launch_risk,data_continuities,params)

if strcmp(params.MODE,'SELECTION')
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [val, i] = min(abs((sciences - xmouse)/xmouse).^2+abs((costs - ymouse)/ymouse).^2);
    xpoint   = sciences(i);
    ypoint   = costs(i);
    arch = archs(i,:);

    fprintf('Arch = %d, utility = %f, Science = %f, Cost = %f, #instruments = %d\n',i,utilities(i),sciences(i),costs(i),sum(archs(i,:)));
    fprintf('Pareto rank = %d, risk = %f, fairness = %f\n',pareto_ranks(i),programmatic_risks(i),fairness_or_launch_risk(i));

    arr = params.instrument_list(logical(archs(i,:)));
    str = StringArraytoStringWithSpaces(arr);
    fprintf('Payload = %s\n',str);
elseif strcmp(params.MODE,'PACKAGING')
    risks = 0.5*(programmatic_risks + fairness_or_launch_risk);
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    [val, i] = min(abs((costs - xmouse)/xmouse).^2+abs((risks - ymouse)/ymouse).^2);
    xpoint   = costs(i);
    ypoint   = risks(i);
    arch = archs(i,:);
    ninstr = cellfun(@length,PACK_arch2sats(archs(i,:)));
    str = PACK_arch_to_str(archs(i,:));
    if params.DATA_CONTINUITY == 1
        fprintf('Arch = %d, utility = %f, Science = %f, Cost = %f, Pareto rank = %d, prog risk = %f, launch risk = %f,data_continuity=%f\n',i,utilities(i),sciences(i),costs(i),pareto_ranks(i),programmatic_risks(i),fairness_or_launch_risk(i),data_continuities(i)); 
    else
        fprintf('Arch = %d, utility = %f, Science = %f, Cost = %f, Pareto rank = %d, prog risk = %f, launch risk = %f\n',i,utilities(i),sciences(i),costs(i),pareto_ranks(i),programmatic_risks(i),fairness_or_launch_risk(i)); 
    end
    fprintf('Arch with %d sats (%s) w/assignment = %s\n',max(archs(i,:)),num2str(ninstr'),str);
elseif strcmp(params.MODE,'SCHEDULING') % archs,discounted_values,data_continuities,utilities,pareto_ranks,programmatic_risks,fairness,params
    mouse = get(gca, 'CurrentPoint');
    xmouse = mouse(1,1);
    ymouse = mouse(1,2);
    discounted_values = sciences;
    data_continuities = costs;
    fairness = fairness_or_launch_risk;
    [val, i] = min(abs((discounted_values - xmouse)/xmouse).^2+abs((data_continuities - ymouse)/ymouse).^2);
    xpoint   = discounted_values(i);
    ypoint   = data_continuities(i);
    arch = archs(i,:);
    
    fprintf('Arch = %d, utility = %f, DV = %f, DC = %f, Pareto rank = %d, risk = %f, fairness = %f\n',i,utilities(i),discounted_values(i),data_continuities(i),pareto_ranks(i),programmatic_risks(i),fairness(i));
    str = SCHED_arch_to_str(archs(i,:));
    fprintf('Sequence = %s\n',str);
end
end