function ranks = frontRanks(fronts, n)
%FRONTRANKS Validate a complete, nonoverlapping partition of the population.
if ~isstruct(fronts) || ~isfield(fronts, 'front') || ~(isvector(fronts) || isempty(fronts))
    error('cn:InvalidFronts', 'A vector of front structs is required.');
end
ranks = zeros(1, n);
for k = 1:numel(fronts)
    indices = fronts(k).front;
    if ~(isnumeric(indices) && isreal(indices) && isvector(indices) && ~isempty(indices) && ...
            all(isfinite(indices(:))) && all(indices(:) == fix(indices(:))) && ...
            all(indices(:) >= 1 & indices(:) <= n))
        error('cn:InvalidFronts', 'Each front must contain valid population indices.');
    end
    indices = double(indices(:).');
    if numel(unique(indices)) ~= numel(indices) || any(ranks(indices) ~= 0)
        error('cn:InvalidFronts', 'An individual occurs more than once.');
    end
    ranks(indices) = k;
end
if any(ranks == 0)
    error('cn:InvalidFronts', 'Fronts must cover the entire population.');
end
end
