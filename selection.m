function parents = selection(population, parentSize, values)
%SELECTION Scalar tournament; pass cached values to select the intended objective.
population = cn.population(population);
if nargin < 3, values = fitness(population); end
if numel(values) ~= numel(population) || any(~isfinite(values(:)))
    error('cn:InvalidFitness', 'One finite fitness value per individual is required.');
end
indices = cn.tournament(ones(1, numel(population)), values, parentSize);
parents = population(indices);
end
