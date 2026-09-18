function G = adjacency(G)
%ADJACENCY Simple undirected, unweighted graph with at least one vertex.
if ~((isnumeric(G) || islogical(G)) && isreal(G) && ismatrix(G) && ...
        ~isempty(G) && size(G, 1) == size(G, 2))
    error('cn:InvalidGraph', 'A nonempty square real adjacency matrix is required.');
end
if any(~isfinite(G(:))) || any(G(:) ~= 0 & G(:) ~= 1) || ...
        any(diag(G) ~= 0) || ~isequal(G, G.')
    error('cn:InvalidGraph', 'Graph must be binary, symmetric and have a zero diagonal.');
end
G = double(G);
end
