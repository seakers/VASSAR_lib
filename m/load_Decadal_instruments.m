function [] = load_Decadal_instruments()
load instruments_measurements
load attrib_correspondance
load names
% fid = - 1;
% filename = [];
% filepath = [];
for instr = 1:length(names)
    instr_name = names{instr};
    indexes1 = find(~strcmp(instruments_measurements(:,2,instr),'None'));
    indexes2 = find(~strcmp(instruments_measurements(:,30,instr),'None')); 
    filepath = 'C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\';
    filename = ['facts_' instr_name '.clp'];

    fid = fopen([filepath filename], 'w');
    % Write header
    fprintf(fid, ['(deffacts measurements-' instr_name '\n']);
    for meas = 1:length(indexes1)
        
        line = instruments_measurements(indexes1(meas),:,instr);
        % Write one line
        param = line{1};
        coverage = line{2};
        hsr = attribute_adapt2(attrib_correspondance,line{3});% ok
        vsr = attribute_adapt2(attrib_correspondance,line{4});% ok
        tr = attribute_adapt2(attrib_correspondance,line{5});% ok
        sr = attribute_adapt2(attrib_correspondance,line{6});% ok
        ss = attribute_adapt2(attrib_correspondance,line{7});% ok
        day = attribute_adapt2(attrib_correspondance,line{8});% ok
        acc = line{9};% ok
        pen = attribute_adapt2(attrib_correspondance,line{10});
        pol = attribute_adapt2(attrib_correspondance,line{11});% if single no else yes
        td = attribute_adapt2(attrib_correspondance,line{12});
        allw = attribute_adapt2(attrib_correspondance,line{13});
        sw = attribute_adapt2(attrib_correspondance,line{14});
        cal = attribute_adapt2(attrib_correspondance,line{15});% OK
        tro = attribute_adapt2(attrib_correspondance,line{16});%ok
        poin = attribute_adapt2(attrib_correspondance,line{17});%ok
        rad = line{9};%ok
        str = ['(Measurement (Parameter "' param '") (Region-of-interest ' coverage ') (Coverage-of-region-of-interest Global) (Horizontal-Spatial-Resolution ' hsr ...
            ') (Vertical-Spatial-Resolution ' vsr ' ) (Temporal-resolution ' tr ') (Spectral-resolution  ' sr ') (Spectral-sampling ' ss ') (Day-Night ' day ' ) (Accuracy ' acc ...
            ') (Penetration ' pen ') (Polarimetry ' pol ') (ThreeD ' td ' ) (All-weather ' allw ' ) (Swath ' sw ') (On-board-calibration ' cal ') (sensitivity-in-low-troposphere-PBL ' tro ...
            ') (Pointing-capability ' poin ' ) (Radiometric-accuracy ' rad '))\n'];
        
        fprintf(fid,str);
        one_measurement = cell(1,20);
        one_measurement{1} = 'Measurement';
        one_measurement{2} = ['Parameter "' param '"'];
        one_measurement{3} = ['Region-of-interest ' coverage];
        one_measurement{4} = ['Coverage-of-region-of-interest Global'];
        one_measurement{5} = ['Horizontal-Spatial-Resolution ' hsr];
        one_measurement{6} = ['Vertical-Spatial-Resolution ' vsr];
        one_measurement{7} = ['Temporal-resolution ' tr];
        one_measurement{8} = ['Spectral-resolution  ' sr];
        one_measurement{9} = ['Spectral-sampling ' ss];
        one_measurement{10} = ['Day-Night ' day];
        one_measurement{11} = ['Accuracy ' acc];
        one_measurement{12} = ['Penetration ' pen];
        one_measurement{13} = ['Polarimetry ' pol];
        one_measurement{14} = ['ThreeD ' td];
        one_measurement{15} = ['All-weather ' allw];
        one_measurement{16} = ['Swath ' sw];
        one_measurement{17} = ['On-board-calibration ' cal];
        one_measurement{18} = ['sensitivity-in-low-troposphere-PBL ' tro];
        one_measurement{19} = ['Pointing-capability ' poin];
        one_measurement{20} = ['Radiometric-accuracy ' rad];
        
        xlswrite('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\test.xlsx',one_measurement,instr_name, ['A' num2str(meas)]);
    end
    for meas = 1:length(indexes2)
        
        line = instruments_measurements(indexes2(meas),:,instr);
        % Write one line
        param = line{1};
        coverage = attribute_adapt2(attrib_correspondance,line{30});
        hsr = attribute_adapt2(attrib_correspondance,line{31});% ok
        vsr = attribute_adapt2(attrib_correspondance,line{32});% ok
        tr = attribute_adapt2(attrib_correspondance,line{33});% ok
        sr = attribute_adapt2(attrib_correspondance,line{34});% ok
        ss = attribute_adapt2(attrib_correspondance,line{35});% ok
        day = attribute_adapt2(attrib_correspondance,line{36});% ok
        acc = line{37};% ok
        pen = attribute_adapt2(attrib_correspondance,line{38});
        pol = attribute_adapt2(attrib_correspondance,line{39});% if single no else yes
        td = attribute_adapt2(attrib_correspondance,line{40});
        allw = attribute_adapt2(attrib_correspondance,line{41});
        sw = attribute_adapt2(attrib_correspondance,line{42});
        cal = attribute_adapt2(attrib_correspondance,line{43});% OK
        tro = attribute_adapt2(attrib_correspondance,line{44});%ok
        poin = attribute_adapt2(attrib_correspondance,line{45});%ok
       
        rad = line{37};%ok
        str = ['(Measurement (Parameter "' param '") (Region-of-interest ' coverage ') (Coverage-of-region-of-interest Global) (Horizontal-Spatial-Resolution ' hsr ...
            ') (Vertical-Spatial-Resolution ' vsr ' ) (Temporal-resolution ' tr ') (Spectral-resolution  ' sr ') (Spectral-sampling ' ss ') (Day-Night ' day ' ) (Accuracy ' acc ...
            ') (Penetration ' pen ') (Polarimetry ' pol ') (ThreeD ' td ' ) (All-weather ' allw ' ) (Swath ' sw ') (On-board-calibration ' cal ') (sensitivity-in-low-troposphere-PBL ' tro ...
            ') (Pointing-capability ' poin ' ) (Radiometric-accuracy ' rad '))\n'];
        
        fprintf(fid,str);
        one_measurement = cell(1,20);
        one_measurement{1} = 'Measurement';
        one_measurement{2} = ['Parameter "' param '"'];
        one_measurement{3} = ['Region-of-interest ' coverage];
        one_measurement{4} = ['Coverage-of-region-of-interest Global'];
        one_measurement{5} = ['Horizontal-Spatial-Resolution ' hsr];
        one_measurement{6} = ['Vertical-Spatial-Resolution ' vsr];
        one_measurement{7} = ['Temporal-resolution ' tr];
        one_measurement{8} = ['Spectral-resolution  ' sr];
        one_measurement{9} = ['Spectral-sampling ' ss];
        one_measurement{10} = ['Day-Night ' day];
        one_measurement{11} = ['Accuracy ' acc];
        one_measurement{12} = ['Penetration ' pen];
        one_measurement{13} = ['Polarimetry ' pol];
        one_measurement{14} = ['ThreeD ' td];
        one_measurement{15} = ['All-weather ' allw];
        one_measurement{16} = ['Swath ' sw];
        one_measurement{17} = ['On-board-calibration ' cal];
        one_measurement{18} = ['sensitivity-in-low-troposphere-PBL ' tro];
        one_measurement{19} = ['Pointing-capability ' poin];
        one_measurement{20} = ['Radiometric-accuracy ' rad];
        xlswrite('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\test.xlsx',one_measurement,instr_name, ['A' num2str(meas)]);
    end
    fprintf(fid,')');        
    fclose(fid);
%     command = ['(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\' filename '")'];
%     r.eval(command);
end
