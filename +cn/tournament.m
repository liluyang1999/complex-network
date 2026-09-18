function indices = tournament(ranks, quality, count)
%TOURNAMENT Lower rank wins, then larger quality; ties choose the first random draw.
if ~(isnumeric(ranks) && isreal(ranks) && isvector(ranks) && ~isempty(ranks) && ...
        all(isfinite(ranks(:))) && all(ranks(:) >= 1) && all(ranks(:) == fix(ranks(:))))
    error('cn:InvalidSelection', 'Positive integer ranks required.');
end
if ~(isnumeric(quality) && isreal(quality) && isvector(quality) && numel(quality) == numel(ranks) && ...
        all(~isnan(quality(:))) && all(quality(:) ~= -Inf))
    error('cn:InvalidSelection', 'One finite or positive-infinite quality per individual is required.');
end
count = cn.integer(count, 'parentSize', 0, 1000);
n = numel(ranks);
indices = ones(1, count);
if n == 1, return; end
for k = 1:count
    pair = randperm(n, 2);
    a = pair(1); b = pair(2);
    if ranks(a) > ranks(b) || (ranks(a) == ranks(b) && quality(a) < quality(b)), a = b; end
    indices(k) = a;
end
end
