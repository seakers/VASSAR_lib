%% Compute_precursors_data_continuity_matrix.m
function Compute_precursors_data_continuity_matrix()
global params
%% Initialize
timeframe = (params.enddate - params.startdate)/params.timestep + 1;
precursors_data_continuity_matrix = cell(params.map_of_measurements.size,timeframe);
for i = 1:params.map_of_measurements.size
    for j = 1:timeframe
        precursors_data_continuity_matrix(i,j) = java.util.ArrayList;
    end
end


%% Populate
for i = 1:147
    % read file
    filename = [params.precursor_missions_xls_path 'm' num2str(i) '.xlsx'];
    disp(['Reading file ' num2str(i) '...']); 
    try
        [~,txt,~] = xlsread(filename);
        meas = txt{2,1};
        % translate CEOS to RBES measurement parameter
        meas2 = params.CEOS_to_RBES_measurements_map.get(meas);
        % get index
        index = params.map_of_measurements.get(meas2);
        for j = 2:size(txt,1)
            ld = txt(j,3);
            eol = txt(j,4);
            miss = txt{j,2};
            instr = txt{j,6};
            [ind1,ind2] = dates_to_indexes(ld,eol,params);
            if params.list_of_missions_tbc.contains(miss)
                for k = ind1:ind2
                    str = [miss '/' instr];
                    if ~precursors_data_continuity_matrix{index,k}.contains(str)
                        precursors_data_continuity_matrix{index,k}.add(str);
                    end
                end
            end
        end
    catch ME
        disp(['File ' num2str(i) ' is empty']); 
    end
    
    
end


%% Output
params.precursors_data_continuity_matrix = precursors_data_continuity_matrix;
params.precursors_data_continuity_boolean_matrix = not(cellfun(@isEmpty,params.precursors_data_continuity_matrix));
params.precursors_data_continuity_integer_matrix = cellfun(@size,params.precursors_data_continuity_matrix);
end

function [ind1,ind2] = dates_to_indexes(ld1,eol1,params)
    tmp = regexp(ld1,'\d?\d/\d?\d/(?<year>\d\d\d\d)','names');
    ld = str2num(tmp{1}.year);
    tmp = regexp(eol1,'\d?\d/\d?\d/(?<year>\d\d\d\d)','names');
    eol = str2num(tmp{1}.year);
    if ld < params.startdate 
        ld = params.startdate;
    end
    if eol < params.startdate 
        eol = params.startdate;
    end
    if ld > params.enddate 
        ld = params.enddate;
    end
    if eol > params.enddate 
        eol = params.enddate;
    end
    ind1 = floor((ld-params.startdate)/params.timestep);
    if(ind1==0)
        ind1=1 ;
    end
    ind2 = floor((eol-params.startdate)/params.timestep) - 1;
end
