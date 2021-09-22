function r = init_KBEOSS2(params,WATCH)
%% Java path
% Add path
% javaaddpath('C:\Documents and Settings\Dani\My Documents\software\Jess71p2\lib\jess.jar');
% javaaddpath('C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\dist\EOLanguage.jar')
% javaaddpath('C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\build\classes\');
for i = 1:length(params.javaaddpath)
    javaaddpath(params.javaaddpath{i});
end

%% Init Jess
import jess.*
r = jess.Rete();
if WATCH
    r.eval('(watch all)');
end
return