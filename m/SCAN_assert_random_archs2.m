function archs = SCAN_assert_random_archs2(NRANDOM)
[~,vv] = get_all_data('ENUMERATION::DECISION',{'name'},{'single-char'},0);
names = cellfun(@char,depack_cellofcells(vv),'UniformOutput',false);
n = length(names);
[~,vv] = get_all_data('ENUMERATION::DECISION',{'type'},{'single-char'},0);
types = cellfun(@char,depack_cellofcells(vv),'UniformOutput',false);
[ref,~] = get_all_data('MANIFEST::ARCHITECTURE',{'id'},{'single-char'},0);
for i = 1:NRANDOM
    call = '';
    for j = 1:n
        % SELECTION
        switch types{j}
            case 'SELECTION'
                [~,vv] = get_all_data(['ENUMERATION::DECISION (name ' names{j} ')'],{'enum-parameters'},{'multi-char'},0);
                elems = vv{1};
                theelems = StringArrayWithSpacestoStringArray(elems{1});
                dec = randi(2^length(theelems)-1);
                bin = de2bi(dec,length(theelems));
                selected = theelems(logical(bin));
                SELECTION = StringArraytoStringWithSpaces(selected);% choose random subset of elements from parameters
                call = horzcat(call,['(' names{j} ' (create$ ' SELECTION ')) ']);
            case 'PACKAGING'
                if isempty(SELECTION)
                    error('SCAN_assert_random_archs2: Set of elements not defined by SELECTION before PACKAGING');
                else
                    elems = selected;
                    if ~iscell(elems)
                        theelems = StringArrayWithSpacestoStringArray(elems);
                    else
                        theelems = elems;
                    end
                    ns = length(theelems);
                    
                    PACKAGING = PACK_fix(randi(ns,[1 ns]));
                    NCONST = max(PACKAGING);
                    call = horzcat(call,['(' names{j} ' (create$ ' num2str(PACKAGING) ')) (num-constel ' num2str(NCONST) ') ']);
                end
            case 'ASSIGNING_STR'
                if isempty(PACKAGING)
                    error('SCAN_assert_random_archs2: Set PARTITION of elements not defined by PACKAGING before ASSIGNING');
                end
                [~,vv] = get_all_data(['ENUMERATION::DECISION (name ' names{j} ')'],{'enum-parameters'},{'multi-char'},0);
                elems = vv{1};elems = elems{1};
                theelems = StringArrayWithSpacestoStringArray(elems);
                ASSIGNING = StringArraytoStringWithSpaces(theelems(randi(length(theelems),[1 NCONST])));
                call = horzcat(call,['(' names{j} ' (create$ ' ASSIGNING ')) ']);
            case 'ASSIGNING_NUM'
                if isempty(PACKAGING)
                    error('SCAN_assert_random_archs2: Set PARTITION of elements not defined by PACKAGING before ASSIGNING');
                end
                [~,vv] = get_all_data(['ENUMERATION::DECISION (name ' names{j} ')'],{'enum-parameters'},{'multi-num'},0);
                elems = vv{1};elems = elems{1};
                ASSIGNING = num2str(elems(randi(length(elems),[1 NCONST])));
                call = horzcat(call,['(' names{j} ' (create$ ' ASSIGNING ')) ']);
            otherwise
                error('SCAN_assert_random_archs2: incorrect type of decision');
        end             
    end
%     call = horzcat(call,')');
%     archs{i} = call;
    jess(['duplicate ' num2str(ref{1}.getFactId) ' (id rand-' num2str(i) ') ' call]);
end
    jess(['retract ' num2str(ref{1}.getFactId)]);
    [archs,~] = get_all_data('MANIFEST::ARCHITECTURE',{'id'},{'single-char'},0);
end
    