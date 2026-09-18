function weights = weights(weights)
if ~(isnumeric(weights) && isreal(weights) && isvector(weights) && numel(weights) == 3 && ...
        all(isfinite(weights(:))) && all(weights(:) >= 0) && any(weights(:) > 0))
    error('cn:InvalidWeights', 'Three finite nonnegative weights, at least one positive, are required.');
end
weights = reshape(double(weights), 1, 3);
end
