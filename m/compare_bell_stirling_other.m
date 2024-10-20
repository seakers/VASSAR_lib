%% compare_bell_stirling_other.m
NINSTR = 3:11;
NSAT = [2 3];
MAX_INSTR_SAT = 6;
bel = zeros(1,length(NINSTR));
stir1= zeros(1,length(NINSTR));
stir2= zeros(1,length(NINSTR));
narc = zeros(1,length(NINSTR));

for i = 1:length(NINSTR)
    n = NINSTR(i);
    bel(i) = Bell(n);
    stir1(i) = stirling(n,NSAT(1));
    stir2(i) = stirling(n,NSAT(2));
    arcs = Enum_partitions(n,NSAT,MAX_INSTR_SAT);
    narc(i) = size(arcs,2);
end
scrsz = get(0,'ScreenSize');
f = figure('Position',[1 0 scrsz(3) scrsz(4)]);
ax = axes('Parent',f,'FontSize',16);
semilogy(NINSTR,bel,'b',NINSTR,stir1,'r',NINSTR,stir2,'g',NINSTR,narc,'k');
grid on;
leg = legend({'Unconstrained-Bell(n)','2sats-Stir(n,2)','3sats-Stir(n,3)','2 or 3 sats, <=6 instr per sat'});
set(leg,'Fontsize',16);
title('Tradespace size for the instrument packaging problem with different constraints','Fontsize',20);
xlabel('# instruments','Fontsize',16);
ylabel('# valid architectures','Fontsize',16);
print('-dmeta','bell_stirling.emf');