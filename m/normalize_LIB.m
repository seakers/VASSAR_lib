function norm = normalize_LIB(metric)
if max(metric) ~= min(metric)
    norm =(metric - min(metric))./(max(metric)- min(metric)); 
else
    norm = metric./min(metric);
end

end
