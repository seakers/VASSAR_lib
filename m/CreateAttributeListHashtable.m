function attribs = CreateAttributeListHashtable(num,txt)
% Create attributeList: attribute hashtable associating characteristics to keys
% Example of use: 
% int index = GlobalVariables.attributeList.get(charac);

% attribs = java.util.Hashtable();
attribs = java.util.HashMap();
nattribs = size(num,1);
for i = 1:nattribs
    line_txt = txt(i+1,:);
    line_num = num(i,:);% num, which is a double matrix and not a cell array, has one line less than txt because txt contains header line
    charact = line_txt{1};
%     id = line_num(1);
%     type = line_txt{3};
    attribs.put(charact,java.lang.Integer(line_num(1)));

end
return