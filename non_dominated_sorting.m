function [fronts, ranks] = non_dominated_sorting(population)
scores = cn.scores(cn.costs(population), 'multi', []);
[fronts, ranks] = cn.nonDominated(scores);
end
