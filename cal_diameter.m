function value = cal_diameter(G)
%CAL_DIAMETER See cn.metrics for graph conventions and disconnected values.
costs = cn.metrics(G);
value = costs(2);
end
