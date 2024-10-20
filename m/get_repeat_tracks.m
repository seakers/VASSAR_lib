function orbits = get_repeat_tracks()
RE = 6378140;
MU = 3.986004418e14;
PE = 86400;
PRECISION = 60/6000;

h = 1000*(400:25:1225);
P = 2*pi./sqrt(MU./((RE+h).^3));
revs = PE./P;%e.g. 14.325
drevs = revs - floor(revs);%e.g. 0.325
% drevs = round(drevs*PRECISION)./PRECISION;
orbits = zeros(length(drevs),3);
ndays = 1:2000;
n = 1;
for i = 1:length(drevs)
%     [n, d] = numden(sym(drevs(i)));
    pot = ndays.*drevs(i);% 
    diff = pot - round(pot);
    ok = abs(diff)<PRECISION;
    d =ndays(find(ok,1));
    if ~isempty(d)
        orbits(n,:) = [1e-3*h(i) d*revs(i) d];
        n = n + 1;
    end
end
orbits(n:end,:) = [];
plot(orbits(:,1),orbits(:,3),'bx');
% axis([575 1275 1 Inf]);

end