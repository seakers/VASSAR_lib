function [jessStr] = excel2jessStr(excelStr)
    jessStr = jess_encode(excel2jessValue(excelStr));
end