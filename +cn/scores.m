function scores = scores(costs, mode, weights)
%SCORES All internal scores are maximized. Public weighted solver returns COST.
switch mode
    case 'difference'
        scores = costs(:, 2) - costs(:, 1);
    case 'weighted'
        denominator = costs * cn.weights(weights).';
        scores = 1 ./ denominator;
    case 'multi'
        scores = 1 ./ costs;
    otherwise
        error('cn:InvalidMode', 'Unknown objective mode.');
end
if any(~isfinite(scores(:))) || (strcmp(mode, 'weighted') && any(scores(:) <= 0))
    error('cn:InvalidFitness', 'Objective overflow or underflow; rescale the weights.');
end
end
