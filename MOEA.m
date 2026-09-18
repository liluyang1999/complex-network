function [bestSolutions, bestMultiFitValues, info] = MOEA(N, p1, p2, options)
%MOEA NSGA-II-style mutation-only search; return the entire FINAL nondominated front.
% Output length varies. Reciprocal objective vectors retain the original cell format.
if nargin < 4, options = struct(); end
[bestSolutions, bestMultiFitValues, info] = cn.evolve(N, p1, p2, 'multi', [], options);
end
