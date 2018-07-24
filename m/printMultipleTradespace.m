
cd('C:\Users\Nozomi\Dropbox\Nozomi - Dani\EON_PATH')

if ~exist('params','var') || isempty(params)
        javaaddpath('.\java\jess.jar');
    javaaddpath('.\java\jxl.jar');
    javaaddpath('./java/combinatoricslib-2.0.jar');
    javaaddpath('./java/commons-lang3-3.1.jar');
    javaaddpath('./java/matlabcontrol-4.0.0.jar');
    javaaddpath( '.\java\EON_PATH.jar' );
    import rbsa.eoss.*
    import rbsa.eoss.local.*
    import java.io.*;
    %         folder = 'C:\Users\DS925\Dropbox\Nozomi - Dani\RBES SMAP for IEEEAero14';
    folder =  'C:\Users\Nozomi\Dropbox\Nozomi - Dani\EON_PATH';
    %         folder = 'C:\Users\SEAK1\Dropbox\Nozomi - Dani\RBES SMAP for IEEEAero14';
    params = rbsa.eoss.local.Params(folder,'FUZZY-ATTRIBUTES','test','normal','');%C:\\Users\\Ana-Dani\\Dropbox\\EOCubesats\\RBES_Cubesats7" OR C:\\Users\\dani\\My Documents\\My Dropbox\\EOCubesats\\RBES_Cubesats7
end


[FileName,PathName,FilterIndex] = uigetfile( './*.rs*','Pick results file','MultiSelect','on' );

for z=1:length(FileName)
    resMngr = rbsa.eoss.ResultManager.getInstance();
    resCol = resMngr.loadResultCollectionFromFile( [PathName FileName{z}] );
    
    results = resCol.getResults;

    x_var = 'benefit';
    y_var = 'life-cycle cost';

    MARKERS = {'x','o','d','s','p','.',...
        'x','o','d','s','p','.',...
        'x','o','d','s','p','.',...
        'x','o','d','s','p','.',...
        'x','o','d','s','p','.'};

    COLORS = {'b','m','k','g','c','r',...
        'm','k','g','c','r','b',...
        'k','g','c','r','b','m',...
        'g','c','r','b','m','k',...
        'c','r','b','m','k','g'};
    narch = results.size;
    xvals = zeros(narch,1);
    yvals = zeros(narch,1);
    for i = 1:narch
        xvals(i) = results.get(i-1).getScience;
        yvals(i) = results.get(i-1).getCost;
    end
    
    labels = {'Pareto Front','Architectures'};
    vals = ones(narch,1);

    unique_vals = unique(vals);
    n = length(unique_vals);
    indexes = cell(n,1);
    markers = MARKERS(1:length(unique_vals));
    colors = COLORS(1:length(unique_vals));
    
    hfig = figure('Visible','off');
    [x_pareto, y_pareto, inds, ~ ] = pareto_front([xvals yvals] , {'LIB', 'SIB'});
    plot( x_pareto, y_pareto, 'r--');
    hold on

    for i = 1 : n
        indexes{i} = (vals == unique_vals(i));
        scatter(xvals(indexes{i}),yvals(indexes{i}),'Marker',markers{i},'MarkerEdgeColor',colors{i});
        xlim( [0 1] );
    end

    grid on;
    xlabel(x_var);
    ylabel(y_var);
    legend(labels,'Location','Best');
    hold off
    name = FileName{z};
    title(name(1:length(name)-3));
    print(hfig,'-dpng',name(1:length(name)-3))
    close(hfig)
end
