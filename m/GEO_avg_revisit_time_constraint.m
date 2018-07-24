function GEO_avg_revisit_time_constraint(avg_TR,scenario_duration,tstep)
%all  inputs should be in seconds

fid = fopen('GEO_avg_revtime.int','w');
fprintf(fid,'%s\n\n','stk.v.10.0');

start_int = cell(1,scenario_duration/avg_TR);
end_int= cell(1,scenario_duration/avg_TR);

t = 0;
i=1;
while t<=scenario_duration
    day=floor(t/(24*60*60));
    hour = floor((t-day*24*60*60)/(60*60));
    min = floor((t-day*24*60*60-hour*60*60)/60);
    sec = t-day*24*60*60-hour*60*60-min*60;
    start_int{i}=strcat(num2str(day),'/',num2str(hour,'%02d'),':',num2str(min,'%02d'),':',num2str(sec,'%02d'));
    t=t+avg_TR-tstep;
    day=floor(t/(24*60*60));
    hour = floor((t-day*24*60*60)/(60*60));
    min = floor((t-day*24*60*60-hour*60*60)/60);
    sec = t-day*24*60*60-hour*60*60-min*60;
    end_int{i}=strcat(num2str(day),'/',num2str(hour,'%02d'),':',num2str(min,'%02d'),':',num2str(sec,'%02d'));
    t=t+tstep;
    i=i+1;
end

fprintf(fid,'%s\n\n%s\n\n%s\n\n','BEGIN IntervalList','DateUnitAbrv MisElap','Begin Intervals');
for j=1:i-1
    fprintf(fid,'"%s"\t',start_int{j});
    fprintf(fid,'"%s"\n',end_int{j});
end
fprintf(fid,'\n\n%s\n\n%s\n\n','END Intervals','END IntervalList');


fclose(fid);