function values = fitness(population)
%FITNESS Maximize diameter minus average path length (the original Q4 objective).
values = cn.scores(cn.costs(population), 'difference', []).';
end
