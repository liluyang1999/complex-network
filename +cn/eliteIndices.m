function indices = eliteIndices(fronts, crowding, count)
n = numel(crowding);
if ~(isnumeric(crowding) && isreal(crowding) && (isvector(crowding) || isempty(crowding)) && ...
        all(~isnan(crowding(:))) && all(crowding(:) >= 0))
    error('cn:InvalidCrowding', 'Crowding distances must be nonnegative, possibly Inf.');
end
ranks = cn.frontRanks(fronts, n);
count = cn.integer(count, 'populationSize', 0, n);
% An explicit original index breaks exact ties reproducibly.
[~, order] = sortrows([ranks(:), -double(crowding(:)), (1:n).'], [1, 2, 3]);
indices = reshape(order(1:count), 1, []);
end
