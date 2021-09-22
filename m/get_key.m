function key = get_key(orbit,subset)
    if isnumeric(orbit)
        orbit = num2str(orbit);
    end
   key = [orbit '@' StringArraytoStringWithSpaces(subset)];
end