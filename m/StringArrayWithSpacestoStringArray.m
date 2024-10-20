function str_array = StringArrayWithSpacestoStringArray(str)

str_array = regexp(str,'\s','split');
end