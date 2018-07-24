function hasSepPattern(filename)
%this function identifies which solutions have any (OR) of the patterns

[labels,dec1,obj] = loadPopulation(filename);

ind = true(size(dec1,1),1);

% %separate3's
%from 0th stage
% ind = and(indSepPattern({'ACE_LID', 'CLAR_ERB','CNES_KaRIN'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'DESD_SAR','GACM_SWIR'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'DESD_LID','GACM_SWIR'},dec1), ind);
% ind = and(indSepPattern({'ACE_LID', 'CNES_KaRIN','DESD_SAR'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'ACE_LID','HYSP_TIR'},dec1), ind);
% ind = and(indSepPattern({'ACE_ORCA', 'CLAR_ERB','DESD_SAR'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'ACE_LID','GACM_SWIR'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'ACE_LID','DESD_SAR'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'CLAR_ERB','CNES_KaRIN'},dec1), ind);
% ind = and(indSepPattern({'ACE_LID', 'ACE_ORCA','GACM_SWIR'},dec1), ind);

% %from 3rd stage
% ind = and(indSepPattern({'ACE_LID', 'ACE_ORCA','POSTEPS_IRS'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'ACE_LID','GACM_VIS'},dec1), ind);
% ind = and(indSepPattern({'ACE_LID', 'GACM_SWIR','POSTEPS_IRS'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'CLAR_ERB','POSTEPS_IRS'},dec1), ind);
% ind = and(indSepPattern({'CLAR_ERB', 'HYSP_TIR','POSTEPS_IRS'},dec1), ind);
% ind = and(indSepPattern({'ACE_LID', 'CNES_KaRIN','GACM_VIS'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'ACE_POL','GACM_SWIR'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'DESD_SAR','POSTEPS_IRS'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'ACE_LID','DESD_LID'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'ACE_LID','HYSP_TIR'},dec1), ind);


% %separate2's
% ind = and(indSepPattern({'CNES_KaRIN', 'GACM_SWIR'},dec1), ind);
% ind = and(indSepPattern({'DESD_LID', 'DESD_SAR'},dec1), ind);
% ind = and(indSepPattern({'ACE_LID', 'ACE_ORCA'},dec1), ind);
% ind = and(indSepPattern({'DESD_SAR', 'GACM_SWIR'},dec1), ind);
% ind = and(indSepPattern({'CLAR_ERB', 'HYSP_TIR'},dec1), ind);
% ind = and(indSepPattern({'GACM_SWIR', 'POSTEPS_IRS'},dec1), ind);
% ind = and(indSepPattern({'ACE_ORCA', 'GACM_SWIR'},dec1), ind);
% ind = and(indSepPattern({'ACE_ORCA', 'ACE_POL'},dec1), ind);
% ind = and(indSepPattern({'ACE_CPR', 'DESD_LID'},dec1), ind);
% ind = and(indSepPattern({'ACE_POL', 'GACM_VIS'},dec1), ind);

%GACM_SWIR not in afternoon orbit
ind = and(not(sum(dec1(:,16:20),2)>1), ind); %has at least one polarimeter
ind = and(not(sum(dec1(:,16),2)==1), ind); %has polarimeter in 1st orbit
ind = and(not(sum(dec1(:,17),2)==1), ind); %has polarimeter in 2nd orbit
ind = and(not(sum(dec1(:,18),2)==1), ind); %has polarimeter in 3rd orbit
% ind = and(not(sum(dec1(:,19),2)==1), ind); %has polarimeter in 4th orbit
ind = and(not(sum(dec1(:,20),2)==1), ind); %has polarimeter in 5th orbit

figure(1)
scatter(-obj(:,1),obj(:,2)*33495.939796,'b')
hold on
scatter(-obj(labels==1,1),obj(labels==1,2)*33495.939796,'c','filled')
scatter(-obj(~ind,1),obj(~ind,2)*33495.939796,'r')
hold off

xlabel('Scientific Benefit')
ylabel('Lifecycle cost ($FY10M)')
axis([0,0.3,0,25000])
set(gca,'FontSize',16);
legend('All solutions','Top 25% of solutions','Solutions with {I_i,I_j,I_k}')

end

function ind = instrumentInd(inst)
%gets the instrument index
if strcmp(inst,'ACE_ORCA')
    ind = 1;
elseif strcmp(inst,'ACE_POL')
    ind = 2;
elseif strcmp(inst,'ACE_LID')
    ind = 3;
elseif strcmp(inst,'CLAR_ERB')
    ind = 4;
elseif strcmp(inst,'ACE_CPR')
    ind = 5;
elseif strcmp(inst,'DESD_SAR')
    ind = 6;
elseif strcmp(inst,'DESD_LID')
    ind = 7;
elseif strcmp(inst,'GACM_VIS')
    ind = 8;
elseif strcmp(inst,'GACM_SWIR')
    ind = 9;
elseif strcmp(inst,'HYSP_TIR')
    ind = 10;
elseif strcmp(inst,'POSTEPS_IRS')
    ind = 11;
elseif strcmp(inst,'CNES_KaRIN')
    ind = 12;
else
    error('Instrument %s is not recognized',inst_i)
end
end


function p = sepDecPattern(inst)
%inst is a cell of instrument names
%p is matrix with possible separate patterns for each orbit
norbs = 5;
p = zeros(norbs,60);
for i=1:length(inst)
    d = instrumentInd(inst{i});
    for j=1:norbs
        p(j,norbs*(d-1)+j)=1;
    end
end
end

function bool = indSepPattern(inst, dec1)
%true if the instruments are separated in all of the orbits, else false
bool = true(size(dec1,1),1);
p = sepDecPattern(inst);
ind = any(dec1*p'==length(inst),2);
bool(ind) = false;
end

function bool = inOrbit(inst, orb, dec1)
%true if the instrument is in the orbit
norbs = 5;
bool = false(size(dec1,1),1);
p = zeros(norbs,60);
p(norbs*(instrumentInd(inst)-1)+orb) = 1;
ind = any(dec1*p'==1,2);
bool(ind) = true;
end
