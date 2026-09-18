function values = multi_obj_fitness(population)
%MULTI_OBJ_FITNESS Legacy cell-of-row-vectors format: {1/L, 1/D, 1/E}.
scores = cn.scores(cn.costs(population), 'multi', []);
values = {scores(:, 1).', scores(:, 2).', scores(:, 3).'};
end
