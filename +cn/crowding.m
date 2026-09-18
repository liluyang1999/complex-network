function distancesOut = crowding(scores, fronts)
%CROWDING Sum normalized neighbor gaps within each Pareto front.
scores = cn.scoreMatrix(scores);
n = size(scores, 1);
cn.frontRanks(fronts, n);
distancesOut = zeros(1, n);
for k = 1:numel(fronts)
    indices = double(fronts(k).front(:).');
    if numel(indices) <= 2
        distancesOut(indices) = Inf;
        continue;
    end
    for objective = 1:size(scores, 2)
        values = scores(indices, objective);
        [values, order] = sort(values);
        if values(end) == values(1), continue; end % No information in a constant objective.
        % Scaling before subtraction also handles [-realmax, realmax] without overflow.
        values = values / max(abs(values));
        span = values(end) - values(1);
        distancesOut(indices(order([1, end]))) = Inf;
        gaps = (values(3:end) - values(1:end-2)) / span;
        interior = indices(order(2:end-1));
        distancesOut(interior) = distancesOut(interior) + gaps.';
    end
end
end
