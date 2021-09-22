function r = load_aircraft_instruments(r)
[~,txt]= xlsread('C:\Documents and Settings\Dani\My Documents\PhD\research\projects\Rule-based System Architecting\EOLanguage\CaseStudies.xlsx','Instruments');
fid = - 1;
filename = [];
filepath = [];
for i = 2:125
    line = txt(i,:);
    instr_name = line{2};
    if (~isempty(instr_name)) % new instrument
        % close previous file if any
        current_instr = instr_name;
        if fid > 0
            fprintf(fid,')');
            fclose(fid);
            command = ['(batch "C:\\Documents and Settings\\Dani\\My Documents\\NetBeansProjects\\EOLanguage\\' filename '")'];
            r.eval(command);
        end
        filepath = 'C:\Documents and Settings\Dani\My Documents\NetBeansProjects\EOLanguage\';
        filename = ['facts_' current_instr '.clp'];

        fid = fopen([filepath filename], 'w');
        % Write header
        fprintf(fid, ['(deffacts measurements-' instr_name '\n']);

    end
    % Write one line
    param = line{3};
    coverage = line{4};
    hsr = line{5};
    tr = line{6};
    ss = line{7};
    acc = line{8};
    pol = line{9};
    sw = line{10};
    cal = line{11};
    rad = line{12};
    
    fprintf(fid,['(Measurement (Parameter "' param '") (LEO-capability ' coverage ') (Horizontal-Spatial-Resolution ' hsr ') (Temporal-resolution ' tr ') (Spectral-sampling ' ss ') (Accuracy ' acc ') (Polarimetry ' pol ') (Swath ' sw ') (On-board-calibration ' cal ') (Radiometric-accuracy ' rad '))\n']);

end
fclose(fid);