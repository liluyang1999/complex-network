function tests = test_network
%TEST_NETWORK Prepared MATLAB function tests; run with assertSuccess(runtests('tests')).
tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testCase.TestData.PreviousPath = path;
addpath(fileparts(fileparts(mfilename('fullpath'))));
end

function teardownOnce(testCase)
path(testCase.TestData.PreviousPath);
end

function setup(testCase)
testCase.TestData.RNG = rng;
rng(123, 'twister');
end

function teardown(testCase)
rng(testCase.TestData.RNG);
end

function testKnownGraphMetrics(testCase)
line = diag(ones(1, 3), 1); line = line + line.';
complete = ones(4) - eye(4);
star = zeros(4); star(1, 2:end) = 1; star(2:end, 1) = 1;
verifyEqual(testCase, cn.metrics(line), [5/3, 3, 3], 'AbsTol', 1e-12);
verifyEqual(testCase, cn.metrics(complete), [1, 1, 6]);
verifyEqual(testCase, cn.metrics(star), [1.5, 2, 3]);
verifyEqual(testCase, [cal_avg_path_len(line), cal_diameter(line), cal_link_num(line)], [5/3, 3, 3], 'AbsTol', 1e-12);
verifyEqual(testCase, cn.metrics(zeros(1)), [0, 0, 0]);
verifyTrue(testCase, check_connected(zeros(1)));
verifyEqual(testCase, cn.metrics(zeros(2)), [Inf, Inf, 0]);
verifyFalse(testCase, check_connected(zeros(2)));
end

function testGraphValidation(testCase)
for invalid = {[], [0 1; 0 0], eye(2), [0 2; 2 0], [0 NaN; NaN 0], ones(2, 3), '01'}
    verifyError(testCase, @() cn.metrics(invalid{1}), 'cn:InvalidGraph');
end
verifyError(testCase, @() fitness({zeros(2)}), 'cn:InfeasibleGraph');
verifyError(testCase, @() multi_obj_fitness({zeros(1)}), 'cn:InfeasibleGraph');
verifyError(testCase, @() fitness({ones(2)-eye(2), ones(3)-eye(3)}), 'cn:InvalidPopulation');
verifyError(testCase, @() init_population(1, 2), 'cn:InvalidInteger');
end

function testSmallInitializationAndBernoulli(testCase)
for n = [2, 3, 8]
    population = init_population(uint8(n), uint8(10));
    verifySize(testCase, population, [1, 10]);
    for k = 1:numel(population), verifyTrue(testCase, check_connected(population{k})); end
end
empty = gen_N_p_random_graphs(2, 4, 0);
full = gen_N_p_random_graphs(2, 4, 1);
verifyEqual(testCase, empty{1}, zeros(4));
verifyEqual(testCase, full{1}, ones(4)-eye(4));
verifyEqual(testCase, init_population(3, 0), cell(1, 0));
verifyError(testCase, @() gen_N_p_random_graphs(1, 4, NaN), 'cn:InvalidProbability');
end

function testMutationContracts(testCase)
line = diag(ones(1, 4), 1); line = line + line.';
complete = ones(5)-eye(5);
added = mutation({line}, 1, 0);
verifyEqual(testCase, cal_link_num(added{1}), 5);
unchanged = mutation({complete}, 1, 0); verifyEqual(testCase, unchanged{1}, complete);
unchanged = mutation({line}, 0, 1); verifyEqual(testCase, unchanged{1}, line);
removed = mutation({complete}, 0, 1); verifyEqual(testCase, cal_link_num(removed{1}), 9);
for k = 1:30
    changed = mutation({line}, 0, 0);
    verifyEqual(testCase, cal_link_num(changed{1}), 4);
    verifyTrue(testCase, check_connected(changed{1}));
    verifyEqual(testCase, diag(changed{1}), zeros(5, 1));
    verifyEqual(testCase, changed{1}, changed{1}.');
end
two = [0 1; 1 0]; changed = mutation({two}, 0, 0); verifyEqual(testCase, changed{1}, two);
verifyError(testCase, @() mutation({line}, 0.8, 0.8), 'cn:InvalidProbability');
verifyError(testCase, @() mutation({line}, 0.3, 0.3, 0), 'cn:InvalidInteger');
end

function testObjectiveDirectionAndSelection(testCase)
line = diag(ones(1, 3), 1); line = line + line.';
complete = ones(4)-eye(4);
population = {line, complete};
verifyEqual(testCase, fitness(population), [4/3, 0], 'AbsTol', 1e-12);
verifyEqual(testCase, weighted_fitness(population, 1, 0, 0), [3/5, 1], 'AbsTol', 1e-12);
parents = selection(population, 20, weighted_fitness(population, 1, 0, 0));
for k = 1:20, verifyEqual(testCase, parents{k}, complete); end
verifyEqual(testCase, selection({line}, 2), {line, line});
verifyEqual(testCase, crow_tour_selection({line}, 2), {line, line});
verifyEqual(testCase, cn.weightTriple(uint8(1), 0.25, 0.5), [1, 0.25, 0.5]);
verifyError(testCase, @() weighted_fitness(population, [], [1 2], 3), 'cn:InvalidWeights');
verifyError(testCase, @() weighted_fitness(population, 0, 0, 0), 'cn:InvalidWeights');
verifyError(testCase, @() weighted_fitness(population, -1, 1, 1), 'cn:InvalidWeights');
verifyError(testCase, @() weighted_fitness(population, realmax, realmax, realmax), 'cn:InvalidFitness');
end

function testParetoAndCrowding(testCase)
scores = [3 1; 2 2; 1 3; 1 1; 0 0; 2 2];
[fronts, ranks] = cn.nonDominated(scores);
verifyEqual(testCase, fronts(1).front, [1 2 3 6]);
verifyEqual(testCase, ranks, [1 1 1 2 3 1]);
distancesOut = cn.crowding(scores, fronts);
verifyFalse(testCase, any(isnan(distancesOut)));
constant = ones(4, 3); allOne = cn.nonDominated(constant);
verifyEqual(testCase, cn.crowding(constant, allOne), zeros(1, 4));
verifyEqual(testCase, cn.crowding([1 1; 1 1], struct('front', [1 2])), [Inf Inf]);
mixed = [0 1; 1 1; 2 1];
verifyEqual(testCase, cn.crowding(mixed, struct('front', [1 2 3])), [Inf 1 Inf]);
extreme = [-realmax; 0; realmax];
verifyEqual(testCase, cn.crowding(extreme, struct('front', [1 2 3])), [Inf 1 Inf]);
verifyEqual(testCase, cn.eliteIndices(allOne, zeros(1, 4), 2), [1 2]);
verifyError(testCase, @() cn.crowding(scores, struct('front', [1 1 2])), 'cn:InvalidFronts');
verifyError(testCase, @() cn.crowding(scores, struct('front', [1 2])), 'cn:InvalidFronts');
verifyError(testCase, @() cn.nonDominated([1 NaN]), 'cn:InvalidFitness');
verifyError(testCase, @() cn.eliteIndices(allOne, [0 NaN 0 0], 2), 'cn:InvalidCrowding');
end

function testLegacyPopulationHelpers(testCase)
population = init_population(4, 8);
values = multi_obj_fitness(population.');
verifySize(testCase, values, [1, 3]); verifySize(testCase, values{1}, [1, 8]);
[fronts, ranks] = non_dominated_sorting(population);
distancesOut = crowding_distance(population, fronts);
next = elite_preservation(population, 5, fronts, distancesOut);
indices = cn.eliteIndices(fronts, distancesOut, 5);
verifyEqual(testCase, next, population(indices));
verifyGreaterThanOrEqual(testCase, ranks, ones(1, 8));
verifySize(testCase, crow_tour_selection(population, 3), [1, 3]);
end

function testSolverBudgetsAndReproducibility(testCase)
options = struct('Seed', uint32(42), 'PopulationSize', uint8(6), 'Generations', uint8(20), 'MaxEvaluations', 19);
before = rng;
[g, value, info] = EA(5, 0.3, 0.3, options);
verifyEqual(testCase, rng, before);
[repeat, repeatValue, repeatInfo] = EA(5, 0.3, 0.3, options);
verifyEqual(testCase, g, repeat); verifyEqual(testCase, value, repeatValue); verifyEqual(testCase, info, repeatInfo);
verifyEqual(testCase, info.Evaluations, 19); verifyEqual(testCase, info.EvaluationHistory, [6 12 18 19]);
verifyGreaterThanOrEqual(testCase, diff(info.BestScoreHistory), zeros(1, 3));
[g, value, info] = EA_weighted_fitness(5, 0.3, 0.3, 1, 2, 3, options);
verifyEqual(testCase, value, cn.metrics(g)*[1;2;3], 'AbsTol', 1e-12);
verifyEqual(testCase, info.Evaluations, 19);
verifyGreaterThanOrEqual(testCase, diff(info.BestScoreHistory), zeros(1, 3));
[graphs, values, info] = MOEA(5, 0.3, 0.3, options);
verifyEqual(testCase, info.Evaluations, 19);
[~, ranks] = cn.nonDominated(1 ./ info.PopulationCosts);
verifyEqual(testCase, info.Costs, info.PopulationCosts(ranks == 1, :));
verifyEqual(testCase, cn.costs(graphs), info.Costs);
verifyEqual(testCase, values{1}, (1 ./ info.Costs(:, 1)).');
verifyEqual(testCase, rng, before);
end

function testZeroGenerationsAndFinalFront(testCase)
options = struct('Seed', 7, 'PopulationSize', 3, 'Generations', 0, 'MaxEvaluations', 3);
[g, value, info] = EA(4, 0.3, 0.3, options);
verifyEqual(testCase, info.Evaluations, 3); verifyEqual(testCase, info.Generations, 0);
verifyEqual(testCase, value, max(info.PopulationCosts(:, 2)-info.PopulationCosts(:, 1)));
verifyTrue(testCase, check_connected(g));
[graphs, values, info] = MOEA(2, 0.3, 0.3, options);
verifyEqual(testCase, numel(graphs), 3); % Previously population(1:10) failed here.
verifyEqual(testCase, values, {ones(1, 3), ones(1, 3), ones(1, 3)});
verifyEqual(testCase, info.Costs, ones(3, 3));
options.PopulationSize = 1; options.Generations = 3; options.MaxEvaluations = 4;
[~, ~, info] = MOEA(3, 0.3, 0.3, options); verifyEqual(testCase, info.Evaluations, 4);
end

function testExhaustiveFourVertexOracle(testCase)
% Independent counting/BFS oracle: 38 connected labeled graphs, 26 Pareto members.
% Enumerate the six possible edges; compare to exact small-graph counts, not optimizer output.
edgeIndices = find(triu(ones(4), 1));
population = {};
for mask = 0:63
    G = zeros(4);
    G(edgeIndices) = bitget(mask, 1:6);
    G = G + G.';
    if check_connected(G), population{end+1} = G; end %#ok<AGROW>
end
verifyEqual(testCase, numel(population), 38);
[fronts, ~] = non_dominated_sorting(population);
verifyEqual(testCase, numel(fronts(1).front), 26);
costs = cn.costs(population(fronts(1).front));
expected = [1 1 6; 7/6 2 5; 4/3 2 4; 3/2 2 3];
verifyEqual(testCase, sortrows(unique(costs, 'rows')), expected, 'AbsTol', 1e-12);
verifyEqual(testCase, [nnz(costs(:,3)==3), nnz(costs(:,3)==4), nnz(costs(:,3)==5), nnz(costs(:,3)==6)], [4 15 6 1]);
end

function testInvalidOptionsAndRngOnFailure(testCase)
verifyError(testCase, @() EA(4, 0.3, 0.3, struct('Unknown', 1)), 'cn:InvalidOptions');
verifyError(testCase, @() EA(4, 0.3, 0.3, struct('Seed', -1)), 'cn:InvalidInteger');
verifyError(testCase, @() EA(4, 0.3, 0.3, struct('MaxEvaluations', 3)), 'cn:InvalidInteger');
before = rng;
verifyError(testCase, @() EA_weighted_fitness(4, 0.3, 0.3, realmax, realmax, realmax, ...
    struct('Seed', 4, 'PopulationSize', 2)), 'cn:InvalidFitness');
verifyEqual(testCase, rng, before);
end

function testRandomGraphStatistics(testCase)
before = rng;
summary = analyze_random_graphs(4, [0 1], 3, 42);
verifyEqual(testCase, summary.ConnectedCount, [0; 3]);
verifyEqual(testCase, summary.MeanL, [Inf; 1]);
verifyEqual(testCase, summary.MeanE, [0; 6]);
verifyTrue(testCase, isnan(summary.ConnectedMeanL(1)));
verifyEqual(testCase, summary.ConnectedMeanL(2), 1);
verifyEqual(testCase, rng, before);
end

function testDemoAndExport(testCase)
before = rng;
demo = run_demo(42, false);
verifyEqual(testCase, demo.EA.Info.Evaluations, 220);
verifyEqual(testCase, rng, before);
directory = tempname;
cleanup = onCleanup(@() removeTestOutput(directory)); %#ok<NASGU>
[runs, points] = run_experiments(directory, 42, 21, 3);
verifyEqual(testCase, height(runs), 3); verifyEqual(testCase, runs.Evaluations, [21;21;21]);
verifyEqual(testCase, height(points), sum(runs.SolutionCount));
saved = load(fullfile(directory, 'experiment.mat'));
verifyEqual(testCase, saved.runs, runs); verifyEqual(testCase, saved.points, points);
verifyEqual(testCase, saved.parameters.SchemaVersion, 1);
verifyTrue(testCase, isfile(fullfile(directory, 'runs.csv')));
verifyTrue(testCase, isfile(fullfile(directory, 'points.csv')));
verifyError(testCase, @() run_experiments(directory, 42, 21, 3), 'cn:OutputDirectory');
verifyEqual(testCase, rng, before);
end

function removeTestOutput(directory)
% Only the three known files inside this test's fresh tempname are owned here.
if isfolder(directory)
    for name = {'runs.csv', 'points.csv', 'experiment.mat'}
        file = fullfile(directory, name{1});
        if isfile(file), delete(file); end
    end
    rmdir(directory);
end
end
