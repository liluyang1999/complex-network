function population = gen_N_p_random_graphs(popSize, N, p)
%GEN_N_P_RANDOM_GRAPHS Independent Bernoulli edges; disconnected samples are retained.
N = cn.integer(N, 'N', 1, 200);
popSize = cn.integer(popSize, 'popSize', 0, 1000);
[p, ~] = cn.probabilities(p, 0);
population = cell(1, popSize);
for k = 1:popSize
    upper = triu(rand(N) < p, 1);
    population{k} = double(upper | upper.');
end
end
