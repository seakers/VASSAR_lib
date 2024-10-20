function inverse = getInverseHashMap2(hm)
%% getInverseHashMap2.m
% This function assumes that hm is a HashMap where:
% keys are strings from {Str1}
% values are ArrayLists of strings from a predetermined but unknown list of
% strings {Str2}
% The function returns the inverse HashMap where: 
% keys are strings from {Str2} that appear at least in one of the value lists of hm  
% values are the lists of strings from {Str1} that have the key as a value in hm

%% start
inverse = java.util.HashMap;% val n --> {key i, key j}
es = hm.entrySet.iterator;
while es.hasNext()
    entr = es.next();
    key = entr.getKey();
    val = entr.getValue();
    inverse.put(val,key);
    
end
end