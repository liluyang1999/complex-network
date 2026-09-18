function options = options(input)
options = struct('PopulationSize', 80, 'Generations', 80, 'Seed', [], ...
    'MaxEvaluations', Inf, 'MutationAttempts', 100);
if ~(isstruct(input) && isscalar(input))
    error('cn:InvalidOptions', 'Options must be a scalar struct.');
end
names = fieldnames(input);
for k = 1:numel(names)
    if ~isfield(options, names{k}), error('cn:InvalidOptions', 'Unknown option: %s.', names{k}); end
    options.(names{k}) = input.(names{k});
end
options.PopulationSize = cn.integer(options.PopulationSize, 'PopulationSize', 1, 1000);
options.Generations = cn.integer(options.Generations, 'Generations', 0, 10000);
options.MutationAttempts = cn.integer(options.MutationAttempts, 'MutationAttempts', 1, 10000);
if ~(isnumeric(options.Seed) && isreal(options.Seed))
    error('cn:InvalidInteger', 'Seed must be [] or a numeric integer.');
end
if ~isempty(options.Seed), options.Seed = cn.integer(options.Seed, 'Seed', 0, 2^32-1); end
budget = options.MaxEvaluations;
if ~(isnumeric(budget) && isreal(budget) && isscalar(budget) && budget == Inf)
    options.MaxEvaluations = cn.integer(budget, 'MaxEvaluations', options.PopulationSize, flintmax);
end
options.MaxEvaluations = double(options.MaxEvaluations);
end
