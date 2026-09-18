function [bestGraph, bestFit, info] = EA(N, p1, p2, options)
%EA Maximize D-L. Optional settings and diagnostics are described in README.md.
if nargin < 4, options = struct(); end
[bestGraph, bestFit, info] = cn.evolve(N, p1, p2, 'difference', [], options);
end
