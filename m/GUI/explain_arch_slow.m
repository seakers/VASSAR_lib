function explain_arch_slow()
global zeResult zeArch AE results2load
h = msgbox(strcat('Loading archs: ',num2str(results2load),' more to load'));
res = AE.evaluateArchitecture(zeArch,'Slow');
fprintf('%s\n',char(res.toString));
zeResult.setExplanations(res.getExplanations);
zeResult.setCapabilities(res.getCapabilities);

%for evaluating new archs
% if zeResult.getCost == -1 || zeResult.getScience == -1
    zeResult.setCost(res.getCost);
    zeResult.setScience(res.getScience)
% end
close(h)
