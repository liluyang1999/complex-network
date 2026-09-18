function value = cal_link_num(G)
%CAL_LINK_NUM Count each undirected edge once without computing shortest paths.
G = cn.adjacency(G);
value = nnz(triu(G, 1));
end
