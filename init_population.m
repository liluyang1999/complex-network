function population = init_population(N, popSize)
%INIT_POPULATION Random recursive spanning tree, then independent extra edges (p=0.3).
% This distribution is NOT uniform over connected graphs and is NOT conditioned G(N,p).
N = cn.integer(N, 'N', 2, 200);
popSize = cn.integer(popSize, 'popSize', 0, 1000);
population = cell(1, popSize);
for k = 1:popSize
    G = zeros(N);
    order = randperm(N);
    for vertex = 2:N
        a = order(vertex); b = order(randi(vertex - 1));
        G(a, b) = 1; G(b, a) = 1;
    end
    extra = triu(rand(N) < 0.3, 1);
    population{k} = double((G ~= 0) | extra | extra.');
end
end
