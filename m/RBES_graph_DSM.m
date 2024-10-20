function RBES_graph_DSM(node_names,A,type,filename)
% graph EOS {
%      MODIS -- AMSR -- MISR;
%      HIRDLS -- TES;
%  }
node_names = cellfun(@(x)strrep(x, '-', '_'),node_names,'UniformOutput',false);
node_names = cellfun(@(x)strrep(x, '3', 'Three'),node_names,'UniformOutput',false);

fid = fopen(filename,'w');
fprintf(fid,'%s\n','graph EOS {');
for i = 1:length(node_names)
    for j = i+1:length(node_names)
        if strcmp(type,'green-only')
            if A(i,j) > 0
                fprintf(fid,'%s\n',[ node_names{i} ' -- ' node_names{j} '  [color="green"];']);
            end
        elseif strcmp(type,'red-only')
            if A(i,j) < 0
                fprintf(fid,'%s\n',[ node_names{i} ' -- ' node_names{j} '  [color="red"];']);
            end
        elseif strcmp(type,'green-red')
            if A(i,j) > 0
                fprintf(fid,'%s\n',[ node_names{i} ' -- ' node_names{j} '  [color="green"];']);
            elseif A(i,j) < 0
                fprintf(fid,'%s\n',[ node_names{i} ' -- ' node_names{j} '  [color="red"];']);
            end
        end
    end
end
fprintf(fid,'%s\n','}');
end

