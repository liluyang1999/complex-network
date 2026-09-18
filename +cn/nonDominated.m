function [fronts, ranks] = nonDominated(scores)
%NONDOMINATED Maximization with strict improvement in at least one objective.
scores = cn.scoreMatrix(scores);
n = size(scores, 1);
dominates = false(n, n);
counts = zeros(1, n);
for i = 1:n
    for j = i+1:n
        if all(scores(i, :) >= scores(j, :)) && any(scores(i, :) > scores(j, :))
            dominates(i, j) = true; counts(j) = counts(j) + 1;
        elseif all(scores(j, :) >= scores(i, :)) && any(scores(j, :) > scores(i, :))
            dominates(j, i) = true; counts(i) = counts(i) + 1;
        end
    end
end
fronts = struct('front', {});
ranks = zeros(1, n);
current = find(counts == 0);
rank = 1;
while ~isempty(current)
    fronts(rank).front = current; %#ok<AGROW>
    ranks(current) = rank;
    next = [];
    for i = current
        for j = find(dominates(i, :))
            counts(j) = counts(j) - 1;
            if counts(j) == 0, next(end+1) = j; end %#ok<AGROW>
        end
    end
    current = sort(next);
    rank = rank + 1;
end
end
