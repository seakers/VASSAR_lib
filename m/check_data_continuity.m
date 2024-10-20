function [data_continuity_score,data_continuity_measurement_scores,data_continuity_matrix] = check_data_continuity(r,params)
%% check_data_continuity.m
% This function: 
% uses the info in the parms structure about the data continuity requirements
% puts a query in the rule based system to get all the measurements in the
% campaign of each required type. Intervals are concetenated as
% appropriate, and a score is calculated as the fraction of overall
% required time during which each measurement is actually taken with the
% required attributes.
% 
% Example of usage: [data_continuity_score,data_continuity_measurement_scores] = check_data_continuity(r,params)
%
% Daniel Selva, June 29th 2011
%

%% Get info from params structure
n = length(params.list_of_measurements_requiring_data_continuity);
timeframe = (params.enddate - params.startdate)/params.timestep + 1;
data_continuity_matrix = params.initial_data_continuity_matrix;

%% Post query in rule based system and fill out data_continuity_matrix
for i = 1:n
    parameter = params.list_of_measurements_requiring_data_continuity{i};
    r.eval(['(bind ?result (run-query* REQUIREMENTS::search-all-measurements-by-parameter "' char(parameter) '"))']);
%     r.eval('(bind ?counter 0)');
    r.eval('(bind ?ld (new java.util.ArrayList))');
    r.eval('(bind ?lt (new java.util.ArrayList))');
    r.eval('(while (?result next) (call ?ld add (?result getString ld)) (call ?lt add (?result getString lt)))');
%     t = tmp.javaObjectValue(r.getGlobalContext());
    t = r.eval('(eq ?ld (create$ nil))');
    if ~t.equals('TRUE')
        ld = r.eval('?ld').javaObjectValue(r.getGlobalContext());% VectorValue ld.get(0), ld.size
        lt = r.eval('?lt').javaObjectValue(r.getGlobalContext());% VectorValue
            for j = 1:ld.size
                ld_val = str2num(ld.get(j-1));
                lt_val = str2num(lt.get(j-1));
                data_continuity_matrix(i,(ld_val-params.startdate)/params.timestep:(ld_val+lt_val-params.startdate)/params.timestep) = 1;

            end
    end
end

%% Process results of query and transform into data continuity scores
data_continuity_measurement_scores = sum(data_continuity_matrix,2);
data_continuity_score = mean(data_continuity_measurement_scores);
return