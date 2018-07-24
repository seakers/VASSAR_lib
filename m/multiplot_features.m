function  multiplot_features(feature_data,feature_num,feature_val)

for i=1:length(feature_data)
    subplot(3,9,i)
    filedata = feature_data{i};
    
    %find unique points on pareto front
    unique_pf_archs = unique([filedata(:,1),filedata(:,2)],'rows');
    
    [a,~] = size(filedata);
    has = zeros(a,1);
    notHas = zeros(a,1);
    for j=1:a
        if filedata(j,feature_num)==feature_val
            has(j) = true;
        else
            notHas(j) = true;
        end
    end    
    
    has_ind = find(has);
    notHas_ind = find(notHas);
    
    %normalize data so everything is in [0,1]
    minSci = min(filedata(:,1));
    maxSci = max(filedata(:,1)-minSci);
    minCost = min(filedata(:,2));
    maxCost = max(filedata(:,2)-minCost);
    
    normSci=(filedata(:,1)-minSci)/maxSci;
    normCost=(filedata(:,2)-minCost)/maxCost;
    normPFSci=(unique_pf_archs(:,1) - minSci)/maxSci;
    normPFCost = (unique_pf_archs(:,2)-minCost)/maxCost;
    
    hold on
    sub_pos = get(gca,'position'); % get subplot axis position
    set(gca,'position',sub_pos.*[1 1 1.2 1.2]) % stretch its width and height
    if i== 1 || i==10 || i==19
        ylabel('Cost ($M)')
    else
        set(gca, 'YTick', []); %get rid of tick marks
    end        
    if i<19
        set(gca, 'XTick', []); %get rid of tick marks
    else
        xlabel('Science')
    end
    plot(normPFSci,normPFCost,'--k','LineWidth',2)
    scatter(normSci(has_ind),normCost(has_ind),'b')
    scatter(normSci(notHas_ind),normCost(notHas_ind),'r')
    title(strcat('Exp',num2str(i)))
    axis([0,1,0,1]);
    hold off
end
