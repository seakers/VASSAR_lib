function [counts0,uniques0,counts1] = RBES_detect_features(archs,indexes,atts,types,varargin)
%% All architectures
    if nargin < 5
        [counts0,uniques0] = count_features(archs,atts,types);
    else
        counts0 = varargin{1};
        uniques0 = varargin{2};
    end
      
    [counts1,~] = count_features(archs(indexes),atts,types,uniques0);
    for i = 1:length(atts)
        count0 = 100*counts0{i}./sum(counts0{i});
        [y0,i0] = max(count0);
        count1 = 100*counts1{i}./sum(counts1{i});
        [y1,i1] = max(count1);
%         if y0~=y1 && length(count0) > 1
%             fprintf('For %s with values %s, original distribution is ',atts{i},StringArraytoStringWithSpaces(uniques0{i}));
%             fprintf('%.0f ',100*count0./sum(count0));
%             fprintf('\n while distrib in cluster is ');
%             fprintf('%.0f ',100*count1./sum(count1));
%             fprintf('\n');
%         end
        if y1>66 && y0<66
            fprintf('%.0f pct archs in cluster have %s = %s, for %.0f pct in orig distribution\n',y1,atts{i},uniques0{i}{i1},y0);
        end
    end
end
function [counts,uniques2] = count_features(archs,atts,types,varargin)
    jess reset;
%     archs = archs(indexes);
%     narch = length(archs);
    assert_string_archs(archs);
    if nargin>3
        uniques2 = varargin{1};
    else
        uniques2 = cell(length(atts),1);
    end
    
    counts = cell(length(atts),1);
    
    for i = 1:length(atts)
        if nargin==3
            [~,values] = get_all_data('MANIFEST::ARCHITECTURE',atts(i),types(i),0);
            vals = depack_cellofcells(values);
            uniques = unique(vals);
        elseif nargin>3
            uniques = uniques2{i};
        end
        n = length(uniques);
        count = zeros(1,n);
        for j = 1:n
            att = uniques(j);
            [facts,~] = my_jess_query(['MANIFEST::ARCHITECTURE (' atts{i} ' ' att{1} ')'],atts{1},0);
            count(j) = length(facts);
%             fprintf('%d from %d archs in cluster (%f pct) have %s = %s\n',count(j),narch,100*count(j)/narch,atts{i},att{1});
        end
        counts{i} = count;
        uniques2{i} = uniques;
    end
end