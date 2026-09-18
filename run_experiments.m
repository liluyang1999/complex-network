function [runs, points] = run_experiments(outputDirectory, seeds, budget, N)
%RUN_EXPERIMENTS Exact, equal objective-evaluation budgets; save only to a NEW directory.
% Algorithms solve different objectives. These tables are not a ranking of algorithms.
if nargin < 1, error('cn:OutputDirectory', 'Provide a new output directory.'); end
if nargin < 2, seeds = 1:5; end
if nargin < 3, budget = 400; end
if nargin < 4, N = 10; end
if isstring(outputDirectory) && isscalar(outputDirectory), outputDirectory = char(outputDirectory); end
if ~(ischar(outputDirectory) && isrow(outputDirectory) && ~isempty(strtrim(outputDirectory))) || ...
        exist(outputDirectory, 'file') ~= 0 || exist(outputDirectory, 'dir') ~= 0
    error('cn:OutputDirectory', 'Output path must be new and nonempty.');
end
N = cn.integer(N, 'N', 2, 200);
budget = cn.integer(budget, 'budget', 20, 200020);
if ~(isnumeric(seeds) && isreal(seeds) && isvector(seeds) && ~isempty(seeds) && numel(seeds) <= 100)
    error('cn:InvalidSeeds', 'Use 1 to 100 distinct seeds.');
end
seeds = double(seeds(:).');
for seed = seeds, cn.integer(seed, 'seed', 0, 2^32-1); end
if numel(unique(seeds)) ~= numel(seeds), error('cn:InvalidSeeds', 'Seeds must be distinct.'); end
options = struct('PopulationSize', 20, 'Generations', ceil((budget - 20) / 20), 'MaxEvaluations', budget);
count = numel(seeds) * 3;
RunID = (1:count).'; Algorithm = cell(count, 1); Seed = zeros(count, 1);
Evaluations = zeros(count, 1); ElapsedSeconds = zeros(count, 1); SolutionCount = zeros(count, 1);
ScalarValue = NaN(count, 1); histories = cell(count, 1); graphs = cell(count, 1);
pointRows = zeros(0, 5); row = 0;
for seed = seeds
    options.Seed = seed;
    for algorithm = {'EA', 'Weighted', 'MOEA'}
        row = row + 1; started = tic;
        switch algorithm{1}
            case 'EA'
                [solution, value, info] = EA(N, 0.3, 0.3, options);
                graphs{row} = {solution}; ScalarValue(row) = value;
            case 'Weighted'
                [solution, value, info] = EA_weighted_fitness(N, 0.3, 0.3, 0.34, 0.33, 0.33, options);
                graphs{row} = {solution}; ScalarValue(row) = value;
            case 'MOEA'
                [graphs{row}, ~, info] = MOEA(N, 0.3, 0.3, options);
        end
        ElapsedSeconds(row) = toc(started);
        if info.Evaluations ~= budget, error('cn:Budget', 'Exact experiment budget was not consumed.'); end
        Algorithm{row} = algorithm{1}; Seed(row) = seed; Evaluations(row) = info.Evaluations;
        SolutionCount(row) = size(info.Costs, 1); histories{row} = info;
        pointRows = [pointRows; repmat(row, SolutionCount(row), 1), (1:SolutionCount(row)).', info.Costs]; %#ok<AGROW>
    end
end
runs = table(RunID, Algorithm, Seed, Evaluations, ElapsedSeconds, SolutionCount, ScalarValue);
points = array2table(pointRows, 'VariableNames', {'RunID', 'Solution', 'L', 'D', 'E'});
parameters = struct('SchemaVersion', 1, 'MATLABVersion', version, 'Computer', computer, ...
    'Seeds', seeds, 'SeedGenerator', 'twister', 'N', N, 'Budget', budget, 'PopulationSize', 20, ...
    'Generations', options.Generations, 'P1', 0.3, 'P2', 0.3, 'Weights', [0.34, 0.33, 0.33], ...
    'MutationAttempts', 100, 'Initialization', 'random recursive tree plus Bernoulli(0.3) extra edges');
if exist(outputDirectory, 'file') ~= 0 || exist(outputDirectory, 'dir') ~= 0
    error('cn:OutputDirectory', 'Output path appeared during computation.');
end
[created, message, messageID] = mkdir(outputDirectory);
if ~created || ~isempty(messageID), error('cn:OutputDirectory', 'Cannot create fresh directory: %s', message); end
writetable(runs, fullfile(outputDirectory, 'runs.csv'));
writetable(points, fullfile(outputDirectory, 'points.csv'));
save(fullfile(outputDirectory, 'experiment.mat'), 'runs', 'points', 'histories', 'graphs', 'parameters');
fprintf('Wrote %d runs to %s\n', height(runs), outputDirectory);
end
