function RBES_Init()
%% Java path
% Add path

global params
% for i = 1:length(params.javaaddpath)
%     javaaddpath(params.javaaddpath{i});
% end

%% Init Jess
import jess.*
r = global_jess_engine();
if params.WATCH
    r.eval('(watch all)');
end
r.eval('(set-reset-globals TRUE)');
return