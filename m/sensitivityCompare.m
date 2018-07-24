
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
    folder =  'C:\Users\Nozomi\Dropbox\Nozomi - Dani\RBES SMAP for IEEEAero14';
    %         folder = 'C:\Users\SEAK1\Dropbox\Nozomi - Dani\RBES SMAP for IEEEAero14';
    params = rbsa.eoss.local.Params(folder,'FUZZY-ATTRIBUTES','test','normal','');%C:\\Users\\Ana-Dani\\Dropbox\\EOCubesats\\RBES_Cubesats7" OR C:\\Users\\dani\\My Documents\\My Dropbox\\EOCubesats\\RBES_Cubesats7
end

[FileName,PathName,FilterIndex] = uigetfile( './*.rs*','Pick results files to compare','MultiSelect','on' );
[~,b]=size(FileName);

resMngr = rbsa.eoss.ResultManager.getInstance();
resCol1 = resMngr.loadResultCollectionFromFile( [PathName '2014-10-12_17-53-53_test.rs'] );
results1 = resCol1.getResults;
narch = results1.size;

improveStats = zeros(b,6);
improveData = zeros(narch,b);

for z=1:b
    resCol2 = resMngr.loadResultCollectionFromFile( [PathName FileName{z}] );
    results2 = resCol2.getResults;
    
    archs1 = cell(narch,1);
    archs2 = cell(narch,1);
    
    for i = 1:narch
        archs1{i} = results1.get(i-1).getArch;
        archs2{i} = results2.get(i-1).getArch;
    end
    
    sci_diff = zeros(narch,1);
    for i=1:narch
        arch1 = archs1{i};
        for j=1:narch
            arch2 = archs2{j};
            if arch1.compareTo(arch2)==0
                sci_diff(i) = arch2.getResult.getScience - arch1.getResult.getScience; %gives improvement in sci score
            end
        end
    end
    
    improveData(:,z) = sci_diff;
    improveStats(z,1)=mean(sci_diff);
    improveStats(z,2)=std(sci_diff);
    improveStats(z,3)=max(sci_diff);
    improveStats(z,4)=min(sci_diff);
    improveStats(z,5)=median(sci_diff);
    improveStats(z,6)=mode(sci_diff);
end