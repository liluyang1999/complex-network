function [costs, connected] = metrics(G)
%METRICS [average shortest path, diameter, number of undirected edges].
G = cn.adjacency(G);
n = size(G, 1);
lengths = distances(graph(G));
connected = all(isfinite(lengths(:)));
if n == 1
    costs = [0, 0, 0];
else
    costs = [sum(lengths(:)) / (n * (n - 1)), max(lengths(:)), nnz(triu(G, 1))];
end
end
