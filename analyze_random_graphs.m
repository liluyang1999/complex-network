function summary = analyze_random_graphs(N, probabilities, sampleSize, seed)
%ANALYZE_RANDOM_GRAPHS Shared samples per p; distinguish unconditional and conditional means.
if nargin < 1, N = 15; end
if nargin < 2, probabilities = 0:0.1:1; end
if nargin < 3, sampleSize = 50; end
if nargin < 4, seed = 42; end
N = cn.integer(N, 'N', 2, 200);
sampleSize = cn.integer(sampleSize, 'sampleSize', 1, 1000);
seed = cn.integer(seed, 'seed', 0, 2^32-1);
if ~(isnumeric(probabilities) && isreal(probabilities) && isvector(probabilities) && ...
        ~isempty(probabilities) && numel(probabilities) <= 1000 && ...
        all(isfinite(probabilities(:))) && all(probabilities(:) >= 0 & probabilities(:) <= 1))
    error('cn:InvalidProbability', 'Use a nonempty vector of at most 1000 probabilities in [0,1].');
end
previous = rng; restore = onCleanup(@() rng(previous)); %#ok<NASGU>
rng(seed, 'twister');
Probability = double(probabilities(:));
count = numel(Probability);
ConnectedCount = zeros(count, 1);
MeanL = zeros(count, 1); MeanD = zeros(count, 1); MeanE = zeros(count, 1);
ConnectedMeanL = NaN(count, 1); ConnectedMeanD = NaN(count, 1);
for k = 1:count
    population = gen_N_p_random_graphs(sampleSize, N, Probability(k));
    costs = zeros(sampleSize, 3); connected = false(sampleSize, 1);
    for j = 1:sampleSize, [costs(j, :), connected(j)] = cn.metrics(population{j}); end
    ConnectedCount(k) = nnz(connected);
    MeanL(k) = mean(costs(:, 1)); MeanD(k) = mean(costs(:, 2)); MeanE(k) = mean(costs(:, 3));
    if any(connected)
        ConnectedMeanL(k) = mean(costs(connected, 1));
        ConnectedMeanD(k) = mean(costs(connected, 2));
    end
end
ConnectedFraction = ConnectedCount / sampleSize;
summary = table(Probability, ConnectedCount, ConnectedFraction, MeanL, MeanD, MeanE, ConnectedMeanL, ConnectedMeanD);
end
