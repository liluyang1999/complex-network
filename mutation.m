function offspring = mutation(parents, p1, p2, maxAttempts)
%MUTATION Add, remove, or rewire one edge while preserving simple connected graphs.
% Rewire removes one old edge and adds one original nonedge, preserving edge count.
% At most maxAttempts distinct removals or sampled rewirings; failure is a no-op.
if nargin < 4, maxAttempts = 100; end
maxAttempts = cn.integer(maxAttempts, 'maxAttempts', 1, 10000);
[p1, p2] = cn.probabilities(p1, p2);
parents = cn.population(parents);
offspring = cell(size(parents));
n = [];
for k = 1:numel(parents)
    G = cn.adjacency(parents{k});
    if size(G, 1) < 2 || ~check_connected(G)
        error('cn:InfeasibleGraph', 'Mutation requires connected graphs with at least 2 vertices.');
    end
    if isempty(n), n = size(G, 1); end
    if size(G, 1) ~= n, error('cn:InvalidPopulation', 'Inconsistent graph sizes.'); end
    [a, b] = find(triu(G, 1));
    [u, v] = find(triu(G == 0, 1));
    choice = rand();
    if choice < p1
        if ~isempty(u)
            edge = randi(numel(u)); G = setEdge(G, u(edge), v(edge), 1);
        end
    elseif choice < p1 + p2
        order = randperm(numel(a), min(numel(a), maxAttempts));
        for edge = order
            candidate = setEdge(G, a(edge), b(edge), 0);
            if check_connected(candidate), G = candidate; break; end
        end
    elseif ~isempty(u)
        for attempt = 1:maxAttempts
            old = randi(numel(a)); fresh = randi(numel(u));
            candidate = setEdge(G, a(old), b(old), 0);
            candidate = setEdge(candidate, u(fresh), v(fresh), 1);
            if check_connected(candidate), G = candidate; break; end
        end
    end
    offspring{k} = G;
end
end

function G = setEdge(G, a, b, value)
G(a, b) = value; G(b, a) = value;
end
