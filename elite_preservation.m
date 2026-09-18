function population = elite_preservation(combined, popSize, fronts, crowding)
combined = cn.population(combined);
if numel(combined) ~= numel(crowding), error('cn:InvalidCrowding', 'Population and distance sizes differ.'); end
population = combined(cn.eliteIndices(fronts, crowding, popSize));
end
