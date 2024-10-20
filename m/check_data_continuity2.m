function [data_continuity_score,data_continuity_matrix2,dcmatrix_without_precursors] = check_data_continuity2
%% check_data_continuity2.m
% This function: 
% uses the info in the parms structure about the data continuity requirements
% puts a query in the rule based system to get all the measurements in the
% campaign of each required type. Intervals are concetenated as
% appropriate, and a score is calculated as the fraction of overall
% required time during which each measurement is actually taken with the
% required attributes.
% 
% Example of usage: [data_continuity_score,data_continuity_measurement_scores] = check_data_continuity2(r,params)
%
% Daniel Selva, June 29th 2011
%
global params
r = global_jess_engine();

%% Get info from params structure
% n = length(params.list_of_measurements_requiring_data_continuity);
n = params.map_of_measurements.size;
timeframe = (params.enddate - params.startdate)/params.timestep + 1;
data_continuity_matrix = zeros(n,timeframe);
measurements = params.map_of_measurements.keySet.toArray;
[row,col] = size(params.precursors_data_continuity_matrix);
data_continuity_matrix2 = cell(row,col);
dcmatrix_without_precursors = cell(row,col);
for i = 1:row
    for j = 1:col
        data_continuity_matrix2(i,j) =  params.precursors_data_continuity_matrix{i,j}.clone();
        dcmatrix_without_precursors(i,j) = java.util.ArrayList;
    end
end

data_continuity_matrix_int = params.precursors_data_continuity_integer_matrix;

%% Post query in rule based system and fill out data_continuity_matrix
for i = 1:n
    parameter = measurements(i);
    index = params.map_of_measurements.get(parameter);
    if params.measurement_weights_for_data_continuity(index) >= 1
        
%         fprintf('DC meas = %s\n',parameter);
        
        r.eval(['(bind ?result (run-query* REQUIREMENTS::search-all-measurements-by-parameter "' parameter '"))']);
        r.eval('(bind ?ld (new java.util.ArrayList))');
        r.eval('(bind ?lt (new java.util.ArrayList))');
        r.eval('(bind ?names (new java.util.ArrayList))');
        r.eval('(while (?result next) (call ?ld add (?result getString ld)) (call ?lt add (?result getString lt)) (call ?names add (str-cat (?result getString flies) "/" (?result getString instr) )))');
        t = r.eval('(eq ?ld (create$ nil))');
        if ~t.equals('TRUE')
            ld = r.eval('?ld').javaObjectValue(r.getGlobalContext());% VectorValue ld.get(0), ld.size
            lt = r.eval('?lt').javaObjectValue(r.getGlobalContext());% VectorValue
            names = r.eval('?names').javaObjectValue(r.getGlobalContext());% VectorValue
                for j = 1:ld.size
                    ld_val = str2num(ld.get(j-1));
                    lt_val = str2num(lt.get(j-1));
                    name = names.get(j-1);
                    ind1 = max(1,round((ld_val-params.startdate)/params.timestep));
                    ind2 = min(round((ld_val+lt_val-params.startdate)/params.timestep),timeframe);
                    data_continuity_matrix(index,ind1:ind2) = data_continuity_matrix(i,ind1:ind2) + 1;
                    for k = ind1:ind2
                        if ~data_continuity_matrix2{index,k}.contains(name)
                            data_continuity_matrix2{index,k}.add(name);
                            dcmatrix_without_precursors{index,k}.add(name);
                            data_continuity_matrix_int(index,k) = data_continuity_matrix_int(index,k) + 1/(data_continuity_matrix_int(index,k)+1);
                        end
                    end
                end
        end
    end
end

%% Process results of query and transform into data continuity scores
data_continuity_matrix_diff = data_continuity_matrix_int - params.precursors_data_continuity_integer_matrix;
data_continuity_matrix_diff(data_continuity_matrix_diff < 0) = 0;%only improvements are considered
data_continuity_score = params.measurement_weights_for_data_continuity*data_continuity_matrix_diff*params.data_continuity_weighting_scheme;

return