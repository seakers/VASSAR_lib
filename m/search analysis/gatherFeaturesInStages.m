%combine features mined from the same stages of differnet runs together
path = '/Users/nozomihitomi/Dropbox/EOSS/problems/climateCentric/result/AIAA JAIS/';
resPath = 'aos_noFilter_noCross_x4/';

stage = 0;
while(true)
    numFeatures = 0;    
    features = {};
    files = dir(strcat(path,resPath,'AIAA_innovize_aos_*_',num2str(stage),'_features.txt'));
    if(isempty(files))
        break;
    end
    
    for i=1:length(files)
        fid = fopen(strcat(path,resPath,files(i).name));
        while(~feof(fid))
            line = fgetl(fid);
            if(strcmp(line(1:2),'//'))
                continue; %skip comments/header
            end
            tmp = strsplit(line,'//');
            numFeatures = numFeatures + 1;
            features{numFeatures} = tmp(2);
        end
        fclose(fid);
    end
    
    saveFile = fopen(strcat(path,resPath,'AIAA_innovize_feats_stage',num2str(stage),'.txt'),'w');
    for i = 1:numFeatures
        fprintf(saveFile, '%s\n', char(features{i}));
    end
    fclose(saveFile);
    
    stage = stage + 1;
end
