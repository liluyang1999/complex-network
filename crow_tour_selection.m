function parents = crow_tour_selection(population, parentSize)
population = cn.population(population);
scores = cn.scores(cn.costs(population), 'multi', []);
[fronts, ranks] = cn.nonDominated(scores);
crowding = cn.crowding(scores, fronts);
parents = population(cn.tournament(ranks, crowding, parentSize));
end
