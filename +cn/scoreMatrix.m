function scores = scoreMatrix(scores)
if ~(isnumeric(scores) && isreal(scores) && ismatrix(scores) && ...
        size(scores, 2) >= 1 && all(isfinite(scores(:))))
    error('cn:InvalidFitness', 'Scores must be a finite real matrix: individuals by objectives.');
end
scores = double(scores);
end
