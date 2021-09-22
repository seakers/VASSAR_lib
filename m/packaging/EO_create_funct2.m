function Population = EO_create_funct2(GenomeLength, FitnessFcn, options)
totalPopulationSize = sum(options.PopulationSize);
Population = ones(totalPopulationSize,GenomeLength);

for i = 1:totalPopulationSize
%     tmp = ones(1,GenomeLength,'int8');
    tmp = ones(1,GenomeLength);
    for n = 2:GenomeLength
%         tmp(n) = int8(1+round(max(tmp)*rand));
        tmp(n) = 1+round(max(tmp)*rand);
    end
    Population(i,:) = tmp;
end

return