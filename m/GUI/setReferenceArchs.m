function [ref_arch,ref_label]=setReferenceArchs()

global AE resCol 

%Path GEOSTAR arch
mapping = java.util.HashMap;
mapping.put('GEO-35788-equat-NA',{'PATH_GEOSTAR'});
ref_arch{1} = rbsa.eoss.Architecture(mapping,1);
ref_arch{1}.setEval_mode('DEBUG');
res = AE.evaluateArchitecture(ref_arch{1},'Slow');
resCol.pushResult(res);
ref_label{1} = '1 x (PATH-GEOSTAR)';

%SSO PM 60+183 arch
mapping = java.util.HashMap;
mapping.put('SSO-600-SSO-DD',[{'EON_50_1','EON_183_1'}]);
mapping.put('SSO-800-SSO-AM',[{'EON_50_1','EON_183_1'}]);
mapping.put('SSO-800-SSO-PM',[{'EON_50_1','EON_183_1'}]);
ref_arch{2} = rbsa.eoss.Architecture(mapping,5);
ref_arch{2}.setEval_mode('DEBUG');
res = AE.evaluateArchitecture(ref_arch{2},'Slow');
resCol.pushResult(res);
ref_label{2} = '5 x (EON-50 & EON-183)';

%SSO PM 118+183 arch
mapping = java.util.HashMap;
mapping.put('SSO-600-SSO-DD',[{'EON_118_1','EON_183_1'}]);
mapping.put('SSO-800-SSO-AM',[{'EON_118_1','EON_183_1'}]);
mapping.put('SSO-800-SSO-PM',[{'EON_118_1','EON_183_1'}]);
ref_arch{3} = rbsa.eoss.Architecture(mapping,5);
ref_arch{3}.setEval_mode('DEBUG');
res = AE.evaluateArchitecture(ref_arch{3},'Slow');
resCol.pushResult(res);
ref_label{3} = '5 x (EON-118 & EON-183)';

%SSO PM ATMS arch
mapping = java.util.HashMap;
mapping.put('SSO-600-SSO-DD',[{'EON_ATMS_1'}]);
mapping.put('SSO-800-SSO-AM',[{'EON_ATMS_1'}]);
mapping.put('SSO-800-SSO-PM',{'EON_ATMS_1'});
ref_arch{4} = rbsa.eoss.Architecture(mapping,5);
ref_arch{4}.setEval_mode('DEBUG');
res = AE.evaluateArchitecture(ref_arch{4},'Slow');
resCol.pushResult(res);
ref_label{4} = '5 x (ATMS)';
end
