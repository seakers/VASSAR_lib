
resMngr = rbsa.eoss.ResultManager.getInstance();
currentDir = cd;

%open all results files that need to analyzed
[FileName,PathName,FilterIndex] = uigetfile( './*.rs*','MultiSelect','off');

resCol = resMngr.loadResultCollectionFromFile( [PathName FileName] );
results = resCol.getResults;

narch = results.size;
xvals = zeros(narch,1);
yvals = zeros(narch,1);
archs = cell(narch,1);
for i = 1:narch
    xvals(i) = results.get(i-1).getScience;
    yvals(i) = results.get(i-1).getCost;
    archs{i} = results.get(i-1).getArch;
end
[x_pareto, y_pareto, inds, ~ ] = pareto_front([xvals yvals] , {'LIB', 'SIB'});

pf_archs = archs(inds);
[a,~]=size(pf_archs);

%% num orbits
%first num is for sats with 0 orbits
%percent arch with n orbits
arch_n_orbit = zeros(a,1);
archs_with_n_orbit = zeros(9,1);
for i=1:narch
    norb = 1;
    for j = 1:length(params.orbit_list)
        tmp = archs{i}.getPayloadInOrbit(params.orbit_list(j));
        if tmp.length>0 == 1
            norb = norb + 1;
        end
    end
    arch_n_orbit(i)=norb;
    archs_with_n_orbit(norb) = archs_with_n_orbit(norb)+1;
end
percent_with_n_orbits = archs_with_n_orbit/narch;

%percent arch with n orbit on pf
n_orbits_on_pf = zeros(9,1);
for i=1:a
    norb = arch_n_orbit(inds(i));
    n_orbits_on_pf(norb) = n_orbits_on_pf(norb)+1;
end
percent_with_n_orbits_pf = n_orbits_on_pf./archs_with_n_orbit;

%percent arch on pf with n orbit 
pf_num_orbits = zeros(9,1);
for i=1:a
    norb = 1;
    for j = 1:length(params.orbit_list)
        tmp = pf_archs{i}.getPayloadInOrbit(params.orbit_list(j));
        if tmp.length>0 == 1
            norb = norb + 1;
        end
    end
    pf_num_orbits(norb) = pf_num_orbits(norb)+1;
end
percent_pf_with_n_orbits = pf_num_orbits./a;

% %% num instrument
% %first num is for sats with 0 instruments
% %percent arch with n instruments
% arch_n_inst = zeros(a,1);
% archs_with_n_inst = zeros(14,1);
% for i=1:narch
%     ninst = 1;
%     for j = 1:length(params.orbit_list)
%         tmp = archs{i}.getPayloadInOrbit(params.orbit_list(j));
%         ninst = ninst + tmp.length;
%     end
%     arch_n_inst(i)=ninst;
%     archs_with_n_inst(ninst) = archs_with_n_inst(ninst)+1;
% end
% percent_with_n_inst = archs_with_n_inst/narch;
% 
% %percent arch with n inst on pf
% n_inst_on_pf = zeros(11,1);
% for i=1:a
%     ninst = arch_n_inst(inds(i));
%     n_inst_on_pf(ninst) = n_inst_on_pf(ninst)+1;
% end
% percent_with_n_inst_pf = n_inst_on_pf./archs_with_n_inst;
% 
% %percent arch on pf with n inst 
% pf_num_inst = zeros(11,1);
% for i=1:a
%     ninst = 1;
%     for j = 1:length(params.orbit_list)
%         tmp = pf_archs{i}.getPayloadInOrbit(params.orbit_list(j));
%         ninst = ninst + tmp.length;
%     end
%     pf_num_inst(ninst) = pf_num_inst(ninst)+1;
% end
% percent_pf_with_n_inst = pf_num_inst./a;

%% num sats per plane
%first num is for sats with 0 instruments
%percent arch with n sats per plane
arch_n_satsPerPlane = zeros(a,1);
archs_with_n_satsPerPlane = zeros(9,1);
for i=1:narch
    nsat = 1;
    nsat = archs{i}.getNsats + nsat;
    arch_n_satsPerPlane(i)=nsat;
    archs_with_n_satsPerPlane(nsat) = archs_with_n_satsPerPlane(nsat)+1;
end
percent_with_n_satsPerPlane = archs_with_n_satsPerPlane/narch;

%percent arch with n sat on pf
n_satsPerPlane_on_pf = zeros(9,1);
for i=1:a
    nsat = arch_n_satsPerPlane(inds(i))+1;
    n_satsPerPlane_on_pf(nsat) = n_satsPerPlane_on_pf(nsat)+1;
end
percent_with_n_satsPerPlane_pf = n_satsPerPlane_on_pf./archs_with_n_satsPerPlane;

%percent arch on pf with n sat 
pf_num_satsPerPlane = zeros(9,1);
for i=1:a
    nsat = 1;
    nsat = pf_archs{i}.getNsats + nsat;
    pf_num_satsPerPlane(nsat) = pf_num_satsPerPlane(nsat)+1;
end
percent_pf_with_n_satsPerPlane = pf_num_satsPerPlane./a;


%% GEO vs no GEO

%percent arch with GEO
arch_with_GEO = zeros(narch,1);
archs_with_GEO = 0;
for i=1:narch
    tmp = archs{i}.getPayloadInOrbit(params.orbit_list(1));
    if tmp.length>0
        arch_with_GEO(i)=1;
        archs_with_GEO = archs_with_GEO+1;
    end
end
percent_with_GEO = archs_with_GEO/narch;

%percent arch with GEO on pf
with_GEO_on_pf = 0;
for i=1:a
    if arch_with_GEO(inds(i))
        with_GEO_on_pf = with_GEO_on_pf+1;
    end
end
percent_with_GEO_pf = with_GEO_on_pf./archs_with_GEO;

%percent arch on pf with GEO  
pf_with_GEO = 0;
for i=1:a
    tmp = pf_archs{i}.getPayloadInOrbit(params.orbit_list(1));
    if tmp.length>0
        arch_with_GEO(i)=1;
        pf_with_GEO = pf_with_GEO+1;
    end
end
percent_pf_with_GEO = pf_with_GEO./a;

%% with combos of 50 + 118 + 183

%percent arch with 118 and 183
arch_with_50 = zeros(narch,1);
arch_with_118 = zeros(narch,1);
arch_with_183 = zeros(narch,1);
arch_with_50_183 = zeros(narch,1);
arch_with_118_183 = zeros(narch,1);
arch_with_50_118_183 = zeros(narch,1);
arch_with_ATMS = zeros(narch,1);
archs_with_50 = 0;
archs_with_118 = 0;
archs_with_183 = 0;
archs_with_50_183 = 0;
archs_with_118_183 = 0;
archs_with_50_118_183 = 0;
archs_with_ATMS = 0;

for i=1:narch
    has_50 = false;
    has_118 = false;
    has_183 = false;
    has_ATMS = false;
    for j = 1:length(params.orbit_list)
        tmp = archs{i}.getPayloadInOrbit(params.orbit_list(j));
        for k=1:tmp.length
            if strcmp(char(tmp(k)),'EON_50_1');
                has_50=1;
            end
            if strcmp(char(tmp(k)),'EON_118_1');
                has_118=1;
            end
            if strcmp(char(tmp(k)),'EON_183_1');
                has_183=1;
            end
            if strcmp(char(tmp(k)),'EON_ATMS_1');
                has_ATMS=1;
            end
        end
    end
    if has_50
        arch_with_50(i)=1;
        archs_with_50 = archs_with_50 +1;
    end
    if has_118
        arch_with_118(i)=1;
        archs_with_118 = archs_with_118 +1;
    end 
    if has_183
        arch_with_183(i)=1;
        archs_with_183 = archs_with_183 +1;
    end 
    if has_50 && has_183
        arch_with_50_183(i)=1;
        archs_with_50_183 = archs_with_50_183 +1;
    end
    if has_118 && has_183
        arch_with_118_183(i)=1;
        archs_with_118_183 = archs_with_118_183 +1;
    end
     if has_50 && has_118 && has_183
        arch_with_118_183(i)=1;
        archs_with_118_183 = archs_with_118_183 +1;
    end
    if has_ATMS
        arch_with_ATMS(i)=1;
        archs_with_ATMS = archs_with_ATMS +1;
    end
end
percent_with_50 = archs_with_50/narch;
percent_with_118 = archs_with_118/narch;
percent_with_183 = archs_with_183/narch;
percent_with_50_183 = archs_with_50_183/narch;
percent_with_118_183 = archs_with_118_183/narch;
percent_with_50_118_183 = archs_with_50_118_183/narch;
percent_with_ATMS = archs_with_ATMS/narch;

%percent arch with GEO on pf
with_50_on_pf = 0;
with_118_on_pf = 0;
with_183_on_pf = 0;
with_50_183_on_pf = 0;
with_118_183_on_pf = 0;
with_50_118_183_on_pf = 0;
with_ATMS_on_pf = 0;
for i=1:a
    if arch_with_50(inds(i))
        with_50_on_pf = with_50_on_pf+1;
    end
    if arch_with_118(inds(i))
        with_118_on_pf = with_118_on_pf+1;
    end
    if arch_with_183(inds(i))
        with_183_on_pf = with_183_on_pf+1;
    end
    if arch_with_50_183(inds(i))
        with_50_183_on_pf = with_50_183_on_pf+1;
    end
    if arch_with_118_183(inds(i))
        with_118_183_on_pf = with_118_183_on_pf+1;
    end
    if arch_with_50_118_183(inds(i))
        with_50_118_183_on_pf = with_50_118_183_on_pf+1;
    end
    if arch_with_ATMS(inds(i))
        with_ATMS_on_pf = with_ATMS_on_pf+1;
    end
end
percent_with_50_pf = with_50_on_pf/archs_with_50_183;
percent_with_118_pf = with_118_on_pf/archs_with_50_183;
percent_with_183_pf = with_183_on_pf/archs_with_50_183;
percent_with_50_183_pf = with_50_183_on_pf/archs_with_50_183;
percent_with_118_183_pf = with_118_183_on_pf/archs_with_118_183;
percent_with_50_118_183_pf = with_50_118_183_on_pf/archs_with_50_183;
percent_with_ATMS_pf = with_ATMS_on_pf/archs_with_ATMS;

%percent arch on pf with GEO  
pf_with_50 = 0;
pf_with_118 = 0;
pf_with_183 = 0;
pf_with_50_183 = 0;
pf_with_118_183 = 0;
pf_with_50_118_183 = 0;
pf_with_ATMS = 0;
for i=1:a
    tmp = pf_archs{i}.getPayloadInOrbit(params.orbit_list(1));
    has_50 = false;
    has_118 = false;
    has_183 = false;
    has_ATMS = false;
    for j = 1:length(params.orbit_list)
        tmp = pf_archs{i}.getPayloadInOrbit(params.orbit_list(j));
        for k=1:tmp.length
            if strcmp(char(tmp(k)),'EON_50_1');
                has_50=true;
            end
            if strcmp(char(tmp(k)),'EON_118_1');
                has_118=true;
            end
            if strcmp(char(tmp(k)),'EON_183_1');
                has_183=true;
            end
            if strcmp(char(tmp(k)),'EON_ATMS_1');
                has_ATMS=true;
            end
        end
    end
    if has_50 
        pf_with_50 = pf_with_50 +1;
    end
    if has_118
        pf_with_118 = pf_with_118 +1;
    end
    if has_183
        pf_with_183 = pf_with_183 +1;
    end
    if has_50 && has_183
        pf_with_50_183 = pf_with_50_183 +1;
    end
    if has_118 && has_183
        pf_with_118_183 = pf_with_118_183 +1;
    end
    if has_50 && has_118 && has_183
        pf_with_50_118_183 = pf_with_50_118_183 +1;
    end
    if has_ATMS
        pf_with_ATMS = pf_with_ATMS +1;
    end
end
percent_pf_with_50 = pf_with_50/a;
percent_pf_with_118 = pf_with_118/a;
percent_pf_with_183 = pf_with_183/a;
percent_pf_with_50_183 = pf_with_50_183/a;
percent_pf_with_118_183 = pf_with_118_183/a;
percent_pf_with_50_118_183 = pf_with_50_118_183/a;
percent_pf_with_ATMS = pf_with_ATMS/a;

%% occupies orbit

%percent arch occupying orbit x
arch_in_GEO = zeros(narch,1);
arch_in_600SSO = zeros(narch,1);
arch_in_600ISS = zeros(narch,1);
arch_in_800SSOAM = zeros(narch,1);
arch_in_800SSOPM = zeros(narch,1);
archs_in_GEO = 0;
archs_in_600SSO = 0;
archs_in_600ISS = 0;
archs_in_800SSOAM = 0;
archs_in_800SSOPM = 0;

for i=1:narch
    for j = 1:length(params.orbit_list)
        tmp = archs{i}.getPayloadInOrbit(params.orbit_list(j));
        if tmp.length>0
            if j==1
                arch_in_GEO(i) = 1;
                archs_in_GEO  = archs_in_GEO+1;
            elseif j==2 
                arch_in_600SSO(i) = 1;
                archs_in_600SSO = archs_in_600SSO+1;
            elseif j==3
                arch_in_600ISS(i) = 1;
                archs_in_600ISS = archs_in_600ISS+1;
            elseif j==4
                arch_in_800SSOAM(i) = 1;
                archs_in_800SSOAM = archs_in_800SSOAM+1;
            elseif j==5
                arch_in_800SSOPM(i) = 1; 
                archs_in_800SSOPM = archs_in_800SSOPM+1;
            end
        end
    end
end
percent_in_GEO = archs_in_GEO/narch;
percent_in_600SSO = archs_in_600SSO/narch;
percent_in_600ISS = archs_in_600ISS/narch;
percent_in_800SSOAM = archs_in_800SSOAM/narch;
percent_in_800SSOPM = archs_in_800SSOPM/narch;

%percent arch with GEO on pf
in_GEO_on_pf = 0;
in_600SSO_on_pf = 0;
in_600ISS_on_pf = 0;
in_800SSOAM_on_pf = 0;
in_800SSOPM_on_pf =0;
for i=1:a
    if arch_in_GEO(inds(i))
        in_GEO_on_pf = in_GEO_on_pf+1;
    end
    if arch_in_600SSO(inds(i))
        in_600SSO_on_pf = in_600SSO_on_pf+1;
    end
    if arch_in_600ISS(inds(i))
        in_600ISS_on_pf = in_600ISS_on_pf+1;
    end
    if arch_in_800SSOAM(inds(i))
        in_800SSOAM_on_pf = in_800SSOAM_on_pf+1;
    end
    if arch_in_800SSOPM(inds(i))
        in_800SSOPM_on_pf = in_800SSOPM_on_pf+1;
    end
end
percent_in_GEO_pf = in_GEO_on_pf/archs_in_GEO;
percent_in_600SSO_pf = in_600SSO_on_pf/archs_in_600SSO;
percent_in_600ISS_pf = in_600ISS_on_pf/archs_in_600ISS;
percent_in_800SSOAM_pf = in_800SSOAM_on_pf/archs_in_800SSOAM;
percent_in_800SSOPM_pf = in_800SSOPM_on_pf/archs_in_800SSOPM;

%percent arch on pf with GEO  
pf_in_GEO = 0;
pf_in_600SSO = 0;
pf_in_600ISS = 0;
pf_in_800SSOAM = 0;
pf_in_800SSOPM = 0;
for i=1:a
    for j = 1:length(params.orbit_list)
        tmp = pf_archs{i}.getPayloadInOrbit(params.orbit_list(j));
        if tmp.length>0
            if j==1
                pf_in_GEO = pf_in_GEO + 1;
            elseif j==2 
                pf_in_600SSO = pf_in_600SSO + 1;
            elseif j==3
                pf_in_600ISS = pf_in_600ISS + 1;
            elseif j==4
                pf_in_800SSOAM = pf_in_800SSOAM + 1;
            elseif j==5
                pf_in_800SSOPM = pf_in_800SSOPM + 1; 
            end
        end
    end
end

percent_pf_in_GEO = pf_in_GEO/a;
percent_pf_in_600SSO = pf_in_600SSO/a;
percent_pf_in_600ISS = pf_in_600ISS/a;
percent_pf_in_800SSOAM = pf_in_800SSOAM/a;
percent_pf_in_800SSOPM = pf_in_800SSOPM/a;

fprintf('\t%% in population\t %% with feature on PF\t %% on PF with feature\n');
fprintf('hasGEO\t %d\t %d\t %d\t\n',percent_with_GEO,percent_with_GEO_pf,percent_pf_with_GEO);
fprintf('has50\t %d\t %d\t %d\t\n',percent_with_50,percent_with_50_pf,percent_pf_with_50);
fprintf('has118\t %d\t %d\t %d\t\n',percent_with_118,percent_with_118_pf,percent_pf_with_118);
fprintf('has183\t %d\t %d\t %d\t\n',percent_with_183,percent_with_183_pf,percent_pf_with_183);
fprintf('hasATMS\t %d\t %d\t %d\t\n',percent_with_ATMS,percent_with_ATMS_pf,percent_pf_with_ATMS);
fprintf('inGEO\t %d\t %d\t %d\t\n',percent_in_GEO,percent_in_GEO_pf,percent_pf_in_GEO);
fprintf('in600ISS\t %d\t %d\t %d\t\n',percent_in_600ISS,percent_in_600ISS_pf,percent_pf_in_600ISS);
fprintf('in600SSO\t %d\t %d\t %d\t\n',percent_in_600SSO,percent_in_600SSO_pf,percent_pf_in_600SSO);
fprintf('in800SSOAM\t %d\t %d\t %d\t\n',percent_in_800SSOAM,percent_in_800SSOAM_pf,percent_pf_in_800SSOAM);
fprintf('in800SSOPM\t %d\t %d\t %d\t\n',percent_in_800SSOPM,percent_in_800SSOPM_pf,percent_pf_in_800SSOPM);