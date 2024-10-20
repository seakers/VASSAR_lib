%% create_ff_clp_files.m
basic_heuristics = {'mutation1bit','crossover1point'};
KI_heuristics = {'improveOrbit','removeInterf','addSynergy'};
n = length(KI_heuristics);
root = './clp/search_heuristic_rules_smap_';
for i = 1:2^n-1
    bin = de2bi(i,n);
    fid_w = fopen([root num2str(i) '.clp'],'w');
    
    for k = 1:length(basic_heuristics)
        fid_r = fopen([root basic_heuristics{k} '.clp'],'r');
        tline = fgets(fid_r);
        while ischar(tline)
            fprintf(fid_w,'%s',tline);
            tline = fgets(fid_r);
        end
            
        fclose(fid_r);
    end
    fprintf(fid_w,'\n');
            
    for j = 1:n
        if bin(j) == 1
            fid_r = fopen([root KI_heuristics{j} '.clp'],'r');
            tline = fgets(fid_r);
            while ischar(tline)
                fprintf(fid_w,'%s',tline);
                tline = fgets(fid_r);
            end   
            fclose(fid_r);
        end
    end
    fclose(fid_w);
end