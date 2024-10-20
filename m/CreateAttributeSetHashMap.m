function hm = CreateAttributeSetHashMap(num,txt)
hm = java.util.HashMap();
nattribs = size(num,1);
for i = 1:nattribs
    line_txt = txt(i+1,:);
    line_num = num(i,:);% num, which is a double matrix and not a cell array, has one line less than txt because txt contains header line
    charact = line_txt{1};
    id = line_num(1);
    type = line_txt{3};
    if or(strcmp(type,'NL'),strcmp(type,'OL')) % NL and OL attributes have a list of valid attribute values behind
        num_accepted_values = line_num(3);
        % Create hashtable with accepted values
        accepted_values = java.util.Hashtable();
        for j = 1:num_accepted_values
            accepted_values.put(line_txt{4+j},java.lang.Integer(j));
        end
        % make attribute of the right kind with accepted_values
        attrib = AttributeBuilder.make(type,charact,'N/A');
        attrib.acceptedValues = accepted_values;
    else
        % make attribute of the right kind, accepted values not needed
        attrib = AttributeBuilder.make(type,charact,'N/A');
    end
    % Add attribute into global AttributeSet HashMap
   hm.put(charact,attrib);

end
return
