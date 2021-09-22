%% create_ff_clp_files2.m
basic_heuristics = {'mutation1bit'};
KI_heuristics = {'randomSearch','crossover1point','improveOrbit','removeInterf','addSynergy','removeSuperfluous','addRandomToSmallSat','removeRandomFromLoadedSat','bestNeighbor','askUserToImprove'};
n = length(KI_heuristics);
root = './clp/search_heuristic_rules_smap_';
look_at = cellfun(@bi2de,{[1 0 0 0 0 0 0 0 0 0],[0 1 0 0 0 0 0 0 0 0],[0 0 1 1 1 1 1 1 0 0],[0 1 1 1 1 1 1 1 0 0],[0 1 0 0 0 0 0 0 0 1]},'UniformOutput',false);
% look_at = 1:2^n-1;
for i = 1:length(look_at);
    num = look_at{i};
    bin = de2bi(num,n);
    fid_w = fopen([root num2str(num) '.clp'],'w');
    
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