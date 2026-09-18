function costs = costs(population)
%COSTS One distance-matrix evaluation per connected individual (at least 2 vertices).
population = cn.population(population);
costs = zeros(numel(population), 3);
n = [];
for k = 1:numel(population)
    [costs(k, :), connected] = cn.metrics(population{k});
    if ~connected || size(population{k}, 1) < 2
        error('cn:InfeasibleGraph', 'Optimization requires connected graphs with at least 2 vertices.');
    end
    if isempty(n), n = size(population{k}, 1); end
    if size(population{k}, 1) ~= n
        error('cn:InvalidPopulation', 'All individuals must have the same number of vertices.');
    end
end
end
