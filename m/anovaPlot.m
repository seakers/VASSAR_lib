

group = {'A1','A1','A1','A2','A2','A2','A3','A3','A3'};
% group = {'B1','B2','B3','B1','B2','B3','B1','B2','B3'};
% group = {'C1','C2','C3','C2','C3','C1','C3','C1','C2'};
budget = [10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,200];
varname = {Budget,VarName3,VarName4,VarName5,VarName6,VarName7,VarName8...
    ,VarName9,VarName10,VarName11,VarName12,VarName13,VarName14,VarName15...
    ,VarName16,VarName17};

for i=1:length(varname)
    p=anova1(varname{i},group);
    h=gcf;
    filename = strcat('Diff_Effect_of_A_',num2str(budget(i)));
    print(h, '-djpeg',filename);
    close(h)
    
    h=gcf;
    filename = strcat('Diff_Effect_of_A_anova_',num2str(budget(i)));
    print(h, '-djpeg',filename);
    close all
end