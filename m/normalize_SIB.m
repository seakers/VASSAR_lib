function norm = normalize_SIB(metric)
if max(metric) ~= min(metric)
    norm =(max(metric) - metric)./(max(metric)- min(metric));
else
    norm = metric./max(metric);
end
end