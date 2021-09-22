function [] = load_measurements()
[~,txt]= xlsread('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\EOLanguage\MeasurementsMaxPerformance.xlsx');

filepath = 'C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\';

for i = 2:size(txt,1)
    filename = ['facts_measurement_' num2str(i-1) '.clp'];
    fid = fopen([filepath filename], 'w');
    fprintf(fid, ['(deffacts measurements-max-performance ' '\n']);
    line = txt(i,:);
    % Write one line
    param = line{1};
    coverage = line{2};
    hsr = line{3};
    tr = line{4};
    ss = line{5};
    acc = line{6};
    pol = line{7};
    sw = line{8};
    cal = line{9};
    rad = line{10};

    fprintf(fid,['(Measurement (Parameter "' param '") (LEO-capability ' coverage ') (Horizontal-Spatial-Resolution ' hsr ') (Temporal-resolution ' tr ') (Spectral-sampling ' ss ') (Accuracy ' acc ') (Polarimetry ' pol ') (Swath ' sw ') (On-board-calibration ' cal ') (Radiometric-accuracy ' rad '))\n']);
    fprintf(fid,')');        
    fclose(fid);
 
%     command = ['(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\' filename '")'];
%     r.eval(command);
end

return