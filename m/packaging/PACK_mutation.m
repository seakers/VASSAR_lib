function mutationChildren = PACK_mutation(parents,options,GenomeLength,FitnessFcn,state,thisScore,thisPopulation,scale,shrink)
%MUTATIONGAUSSIAN Gaussian mutation.
%   MUTATIONCHILDREN = MUTATIONGAUSSIAN(PARENTS,OPTIONS,GENOMELENGTH,...
%   FITNESSFCN,STATE,THISSCORE,THISPOPULATION,SCALE,SHRINK) Creates the
%   mutated children using the Gaussian distribution.
%
%   SCALE controls what fraction of the gene's range is searched. A
%   value of 0 will result in no change, a SCALE of 1 will result in a
%   distribution whose standard deviation is equal to the range of this gene.
%   Intermediate values will produce ranges in between these extremes.
%
%   SHRINK controls how fast the SCALE is reduced as generations go by.
%   A SHRINK value of 0 will result in no shrinkage, yielding a constant search
%   size. A value of 1 will result in SCALE shrinking linearly to 0 as
%   GA progresses to the number of generations specified by the options
%   structure. (See 'Generations' in GAOPTIMSET for more details). Intermediate
%   values of SHRINK will produce shrinkage between these extremes.
%   Note: SHRINK may be outside the interval (0,1), but this is ill-advised.
%
%   Example:
%     options = gaoptimset('MutationFcn',{@mutationgaussian});
%
%   This specifies that the mutation function used will be
%   MUTATIONGAUSSIAN, and since no values for SCALE or SHRINK are specified
%   the default values are used.
%
%     scale = 0.5; shrink = 0.75;
%     options = gaoptimset('MutationFcn',{@mutationgaussian,scale,shrink});
%
%   This specifies that the mutation function used will be
%   MUTATIONGAUSSIAN, and the values for SCALE or SHRINK are specified
%   as 0.5 and 0.75 respectively.
%

%   Copyright 2003-2007 The MathWorks, Inc.
%   $Revision: 1.10.4.5 $  $Date: 2007/10/15 22:51:13 $

% Use default parameters if the are not passed in.
% If these defaults are not what you prefer, you can pass in your own
% values when you set the mutation function:
%
% options.MutationFunction = { mutationgaussian, 0.3, 0} ;
%

if(strcmpi(options.PopulationType,'doubleVector'))

    if nargin < 9 || isempty(shrink)
        shrink = 1;
        if nargin < 8 || isempty(scale)
            scale = 1;
        end
    end

    if (shrink > 1) || (shrink < 0)
        msg = sprintf('Shrink factors that are less than zero or greater than one may \n\t\t result in unexpected behavior.');
        warning('gads:mutationgaussian:shrinkFactor',msg);
    end

    scale = scale - shrink * scale * state.Generation/options.Generations;

    range = options.PopInitRange;
    lower = range(1,:);
    upper = range(2,:);
    scale = scale * (upper - lower);

    mutationChildren = zeros(length(parents),GenomeLength);
    for i=1:length(parents)
        parent = thisPopulation(parents(i),:);
        mutationChildren(i,:) = parent  + round(scale .* randn(1,length(parent)));
    end
elseif(strcmpi(options.PopulationType,'bitString'))
    % there's no such thing as binary Gaussian mutation se we'll just
    % revert to uniform.
    mutationChildren = mutationuniform(parents ,options, GenomeLength,FitnessFcn,state, thisScore,thisPopulation);
end
