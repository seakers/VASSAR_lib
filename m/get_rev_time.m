function times = get_rev_time(fov,np,ns,h,i,raan,TALK)
% (num-of-planes# 4) (num-of-sats-per-plane# 1) (orbit-altitude# 800) (orbit-type nil) (orbit-inclination SSO) (orbit-raan PM) (instrument-field-of-view# 35) (avg-revisit-time-global# 5.4021) (avg-revisit-time-tropics# 6.3881) (avg-revisit-time-northern-hemisphere# 4.7062) (avg-revisit-time-southern-hemisphere# 4.7051) (avg-revisit-time-cold-regions# 3.6115) (avg-revisit-time-US# 5.2536))
    jess(['defquery DATABASE::get-revisit-time ' ...
                '?f <- (DATABASE::Revisit-time-of (num-of-planes# ' num2str(np) ') (num-of-sats-per-plane# ' num2str(ns) ') (orbit-altitude# ' num2str(h) ') (orbit-inclination ' i ') (orbit-raan ' raan ') (instrument-field-of-view# ' num2str(fov) ' ) ' ...
                '(avg-revisit-time-global# ?glob) (avg-revisit-time-tropics# ?trop) (avg-revisit-time-northern-hemisphere# ?nh) (avg-revisit-time-southern-hemisphere# ?sh) (avg-revisit-time-cold-regions# ?cold) (avg-revisit-time-US# ?us))']);
            
    result = jess('run-query* DATABASE::get-revisit-time');
    

    while result.next()
        glob = result.getDouble('glob');
        trop = result.getDouble('trop');
        nh = result.getDouble('nh');
        sh = result.getDouble('sh');
        cold = result.getDouble('cold');
        us = result.getDouble('us');
        times = [glob trop nh sh cold us];
        if TALK
            fprintf('glob trop nh sh cold us = ');
            fprintf(' %.1f ', times);
            fprintf('\n');
        end
    end
    
end