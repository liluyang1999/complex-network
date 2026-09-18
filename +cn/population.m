function population = population(population)
%POPULATION Normalize a cell vector; individual graph validation is done by callers.
if ~iscell(population) || ~(isvector(population) || isempty(population))
    error('cn:InvalidPopulation', 'Population must be a cell vector.');
end
population = reshape(population, 1, []);
end
