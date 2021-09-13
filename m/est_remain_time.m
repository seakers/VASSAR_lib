function est_remain_time(i,narc,e_time,l_time)
    if i > 1
        r_arc = narc - i + 1;% number of archs remaining to eval
        r_time = [r_arc*l_time r_arc*e_time/(i-1)];% min/max remaining time
        minr_time = min(r_time)/60;maxr_time = max(r_time)/60;
        fprintf('Evaluating arch %d of %d. Est remaining time = [%.1f;%.1f] min\n',i,narc,minr_time,maxr_time);
    else
        fprintf('Evaluating arch %d of %d...\n',i,narc);
    end
end