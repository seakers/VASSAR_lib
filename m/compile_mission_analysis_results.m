function write_to_excel = compile_mission_analysis_results(results)
m = length(results);
n = length(results{1}.all_avg_rev_times);
write_to_excel = zeros(m,n);
for i = 1:m
    line = results{i}.all_avg_rev_times;% [params | results]
    % put 12345 as incidence for SSO
    if line(4)>90 && line(4) < 100 
        line(4) = 12345;
    end
    
    line(5) = RAAN_to_LTAN(line(5));%RAAN -> LTAN
    
    %put 1000h as revisit time in cold regions for tropical orbits
    if line(4) < 60
        line(11) = 1000;
    end
    
    write_to_excel(i,:) = line;
    
end
write_to_excel(m+1:end,:) = [];
end