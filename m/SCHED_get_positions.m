function [positions,tiers,good_dc,good_dv] = SCHED_get_positions(archs,results)
global params
r = global_jess_engine();
ref = SCHED_ref_arch()
[narc,nmiss] = size(archs);

dcs = results.data_continuities;
dvs = results.discounted_values;

positions = zeros(nmiss,narc);
tiers = zeros(nmiss,narc);

for i = 1:nmiss
    for j = 1:narc
        positions(i,j) = find(archs(j,:) == i,1);
        if positions(i,j) <= 3
            tiers(i,j) = 1;
        elseif positions(i,j) <= 7
            tiers(i,j) = 2;
        else
            tiers(i,j) = 3;
        end
    end
end

[y1,i1] = sort(dcs,'descend');
[y2,i2] = sort(dvs,'descend');
good_dc = i1(1:round(narc/3));
good_dv = i2(1:round(narc/3));

% figure;boxplot(positions',params.SCHEDULING_MissionNames);
% title('All architectures');
% scrsz = get(0,'ScreenSize');
% figure1 = figure('Position',[1 0 0.9*scrsz(3) 0.9*scrsz(4)]);
subplot(2,1,1);boxplot(positions(:,good_dc)',params.SCHEDULING_MissionNames,'colors','g');
hold on;
plot(cell2mat(jess_value(r.eval(['(sequence-to-ordering (create$ ' num2str(ref.arch) '))']))),'rs','MarkerFaceColor','r')
title('Top architectures in dc');
grid on;
% savepath = [params.path_save_results 'scheduling\'];
% tmp = clock();
% hour = num2str(tmp(4));
% minu = num2str(tmp(5));
% filesave = [savepath 'SCHED--mission-positions-' date '-' hour '-' minu '.emf'];
% print('-dmeta',filesave);

subplot(2,1,2);boxplot(positions(:,good_dv)',params.SCHEDULING_MissionNames,'colors','b');
hold on;
plot(cell2mat(jess_value(r.eval(['(sequence-to-ordering (create$ ' num2str(ref.arch) '))']))),'rs','MarkerFaceColor','r')
title('Top architectures in dv');
grid on;

% filesave = [savepath 'SCHED--mission-positions-' date '-' hour '-' minu '.emf'];
% print('-dmeta',filesave);
end