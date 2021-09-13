function attribs_to_keys = CreateAttributeKeysHashMap(num,txt)
% Create attributeKeys: attribute hashtable associating keys to characteristics
% Example of use: 
% String charact = GlobalVariables.attributeKeys.get(new Integer(i)).toString();
attribs_to_keys = java.util.HashMap();
nattribs = size(num,1);
for i = 1:nattribs
    line_txt = txt(i+1,:);
    line_num = num(i,:);% num, which is a double matrix and not a cell array, has one line less than txt because txt contains header line
    charact = line_txt{1};
%     id = line_num(1);
%     type = line_txt{3};
    attribs_to_keys.put(java.lang.Integer(line_num(1)),charact);

end
return