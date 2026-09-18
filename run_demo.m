function results = run_demo(seed, showPlot)
%RUN_DEMO Small seeded example; returns raw costs and makes no files.
if nargin < 1, seed = 42; end
if nargin < 2, showPlot = false; end
if ~(islogical(showPlot) && isscalar(showPlot)), error('cn:InvalidPlot', 'showPlot must be a logical scalar.'); end
options = struct('Seed', seed, 'PopulationSize', 20, 'Generations', 10, 'MaxEvaluations', 220);
[results.EA.Graph, results.EA.Value, results.EA.Info] = EA(8, 0.3, 0.3, options);
[results.Weighted.Graph, results.Weighted.Value, results.Weighted.Info] = EA_weighted_fitness(8, 0.3, 0.3, 0.34, 0.33, 0.33, options);
[results.MOEA.Graphs, results.MOEA.Values, results.MOEA.Info] = MOEA(8, 0.3, 0.3, options);
fprintf('EA D-L: %.6g; weighted COST: %.6g; final Pareto members: %d\n', ...
    results.EA.Value, results.Weighted.Value, numel(results.MOEA.Graphs));
if showPlot
    % Plot layouts may consume randomness; isolate them from the caller too.
    previous = rng; restore = onCleanup(@() rng(previous)); %#ok<NASGU>
    figure('Name', 'Complex network teaching demo');
    subplot(1, 3, 1); plot(graph(results.EA.Graph)); title('Maximize D-L');
    subplot(1, 3, 2); plot(graph(results.Weighted.Graph)); title('Minimize weighted cost');
    costs = results.MOEA.Info.Costs;
    subplot(1, 3, 3); scatter3(costs(:, 1), costs(:, 2), costs(:, 3), 30, 'filled');
    xlabel('Average path L'); ylabel('Diameter D'); zlabel('Edges E');
    title('Final nondominated population'); grid on;
end
end
