function value = cal_avg_path_len(G)
%CAL_AVG_PATH_LEN See cn.metrics for graph conventions and disconnected values.
costs = cn.metrics(G);
value = costs(1);
end
