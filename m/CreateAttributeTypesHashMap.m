function attribTypes = CreateAttributeTypesHashMap(num,txt)
% Create attributeTypes: attribute hashtable associating types to characteristics
% Example of use: 
% String typ = GlobalVariables.attributeTypes.get(charact).toString();
attribTypes = java.util.HashMap();
nattribs = size(num,1);
for i = 1:nattribs
    line_txt = txt(i+1,:);
%     line_num = num(i,:);% num, which is a double matrix and not a cell array, has one line less than txt because txt contains header line
    charact = line_txt{1};
%     id = line_num(1);
    type = line_txt{3};
    attribTypes.put(charact,type);

end
return