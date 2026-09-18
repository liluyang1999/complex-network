function [bestGraph, bestFw, info] = EA_weighted_fitness(N, p1, p2, a1, a2, a3, options)
%EA_WEIGHTED_FITNESS Minimize a1*L+a2*D+a3*E; the second output is COST, not fitness.
if nargin < 7, options = struct(); end
weights = cn.weightTriple(a1, a2, a3);
[bestGraph, bestFw, info] = cn.evolve(N, p1, p2, 'weighted', weights, options);
end
