function values = weighted_fitness(population, a1, a2, a3)
%WEIGHTED_FITNESS Maximize the reciprocal of weighted cost; weights need not sum to 1.
weights = cn.weightTriple(a1, a2, a3);
values = cn.scores(cn.costs(population), 'weighted', weights).';
end
