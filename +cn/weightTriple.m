function weights = weightTriple(a1, a2, a3)
%WEIGHTTRIPLE Validate before concatenation: mixed integer types must not truncate fractions.
items = {a1, a2, a3};
weights = zeros(1, 3);
for k = 1:3
    item = items{k};
    if ~(isnumeric(item) && isreal(item) && isscalar(item) && isfinite(item) && item >= 0)
        error('cn:InvalidWeights', 'Each weight must be a finite nonnegative numeric scalar.');
    end
    weights(k) = double(item);
end
weights = cn.weights(weights);
end
