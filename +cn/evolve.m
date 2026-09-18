function [solutions, values, info] = evolve(N, p1, p2, mode, weights, inputOptions)
%EVOLVE Shared evaluation accounting and objective-consistent selection.
N = cn.integer(N, 'N', 2, 200);
[p1, p2] = cn.probabilities(p1, p2);
options = cn.options(inputOptions);
if strcmp(mode, 'weighted'), weights = cn.weights(weights); end
if ~isempty(options.Seed)
    previous = rng;
    restore = onCleanup(@() rng(previous)); %#ok<NASGU>
    rng(options.Seed, 'twister');
end
population = init_population(N, options.PopulationSize);
costs = cn.costs(population);
scores = cn.scores(costs, mode, weights);
evaluations = numel(population);
historyEvaluations = zeros(1, options.Generations + 1);
historyBest = NaN(1, options.Generations + 1);
historyFront = NaN(1, options.Generations + 1);
completed = 0;
for generation = 0:options.Generations
    slot = generation + 1;
    historyEvaluations(slot) = evaluations;
    if strcmp(mode, 'multi')
        [fronts, ranks] = cn.nonDominated(scores);
        quality = cn.crowding(scores, fronts);
        historyFront(slot) = numel(fronts(1).front);
    else
        ranks = ones(1, numel(population));
        quality = scores.';
        historyBest(slot) = max(scores);
    end
    completed = generation;
    if generation == options.Generations || evaluations >= options.MaxEvaluations, break; end
    childCount = min(options.PopulationSize, options.MaxEvaluations - evaluations);
    indices = cn.tournament(ranks, quality, childCount);
    children = mutation(population(indices), p1, p2, options.MutationAttempts);
    childCosts = cn.costs(children);
    childScores = cn.scores(childCosts, mode, weights);
    evaluations = evaluations + childCount;
    combined = [population, children];
    combinedCosts = [costs; childCosts];
    combinedScores = [scores; childScores];
    if strcmp(mode, 'multi')
        fronts = cn.nonDominated(combinedScores);
        crowding = cn.crowding(combinedScores, fronts);
        keep = cn.eliteIndices(fronts, crowding, options.PopulationSize);
    else
        [~, keep] = sort(combinedScores, 'descend');
        keep = keep(1:options.PopulationSize);
    end
    population = reshape(combined(keep), 1, []);
    costs = combinedCosts(keep, :);
    scores = combinedScores(keep, :);
end
if strcmp(mode, 'multi')
    fronts = cn.nonDominated(scores);
    chosen = fronts(1).front;
    solutions = population(chosen);
    values = {scores(chosen, 1).', scores(chosen, 2).', scores(chosen, 3).'};
else
    [~, chosen] = max(scores);
    solutions = population{chosen};
    if strcmp(mode, 'weighted'), values = costs(chosen, :) * weights.';
    else, values = scores(chosen); end
end
info = struct('Options', options, 'Mode', mode, 'Weights', weights, 'N', N, ...
    'P1', p1, 'P2', p2, 'Evaluations', evaluations, 'Generations', completed, ...
    'Costs', costs(chosen, :), 'PopulationCosts', costs, ...
    'EvaluationHistory', historyEvaluations(1:completed+1), ...
    'BestScoreHistory', historyBest(1:completed+1), ...
    'FrontSizeHistory', historyFront(1:completed+1));
end
