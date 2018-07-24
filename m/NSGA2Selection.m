function [selected_xvals,selected_yvals,ind] = NSGA2Selection(xvals,yvals,num2Keep)
%this function takes in 2 vectors of metrics where xval(1) and yval(1) are
%the metrics obtained from the first solutio in the vector. The function
%returns the vector of x and y values of the selected solutions and their
%indices

%naive method of recursively calling pareto_front method
data = [xvals,yvals,[1:1:length(xvals)]'];
ind = [];
while ~isempty(data)
    [~, ~, index, ~ ] = pareto_front([data(:,1),data(:,2)] , {'LIB', 'SIB'});
    if length([ind,index])>num2Keep
        [~,~,cd_ind]=crowdingDistSelection(data(index,1),data(index,2),num2Keep-length(ind));
        ind = [ind,data(index(cd_ind),3)'];
        break
    else
        ind = [ind,data(index,3)'];
    end
    data(index,:) = [];
end

selected_xvals = xvals(ind);
selected_yvals = yvals(ind);