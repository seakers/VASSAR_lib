function load_instrument_database
%% load_instrument_database.m
global params
r = global_jess_engine();
instrument_list1 = params.instrument_list;
if isfield(params,'packaging_instrument_list') && isfield(params,'scheduling_instrument_list')
    instrument_list2 = params.packaging_instrument_list;
    instrument_list3 = params.scheduling_instrument_list;
    instrument_list = unique([instrument_list1' instrument_list2 instrument_list3])';
else
    instrument_list = instrument_list1;
end
    


[~,txt,raw]= xlsread(params.capability_rules_xls,'CHARACTERISTICS');
call = '(deffacts instrument-database-facts "Instrument facts" ';
n = size(txt,1);

for i = 2:n
    line = txt(i,:);
    if sum(cellfun(@(x)strcmp(x,txt{i,1}),instrument_list))>0
        call = [call ' (DATABASE::Instrument (Name ' txt{i,1} ') '];
        for j = 2:length(line)
            att_value_pair = line{j};
%             fprintf('%s %s\n',txt{i,1},att_value_pair);
            call = [call ' (' att_value_pair ') '];
        end
        call = [call ') '];
    end
end

trls = zeros(n-1,1);
kk = 1;
for i = 2:n
    line = txt(i,:);
    if sum(cellfun(@(x)strcmp(x,txt{i,1}),instrument_list1))>0
        call = [call ' (DATABASE::Instrument (Name ' txt{i,1} ') '];
        for j = 2:length(line)
            att_value_pair = line{j};
            if strncmp(att_value_pair,'Technology-Readiness-Level',26)
                trls(kk) = str2num(att_value_pair(end));
                kk = kk + 1;
            end
            call = [call ' (' att_value_pair ') '];
        end
        call = [call ') '];
    end
end
params.instrument_trls = trls(1:kk-1);
call = [call ')'];
r.eval(call);
end