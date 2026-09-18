function values = crowding_distance(population, fronts)
scores = cn.scores(cn.costs(population), 'multi', []);
values = cn.crowding(scores, fronts);
end
