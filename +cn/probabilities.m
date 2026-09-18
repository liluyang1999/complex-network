function [p1, p2] = probabilities(p1, p2)
if ~(isnumeric(p1) && isreal(p1) && isscalar(p1) && isfinite(p1) && p1 >= 0 && p1 <= 1) || ...
        ~(isnumeric(p2) && isreal(p2) && isscalar(p2) && isfinite(p2) && p2 >= 0 && p2 <= 1)
    error('cn:InvalidProbability', 'Probabilities must be finite scalars in [0, 1].');
end
p1 = double(p1); p2 = double(p2);
if p1 + p2 > 1
    error('cn:InvalidProbability', 'p1 + p2 must not exceed 1.');
end
end
