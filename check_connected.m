function connected = check_connected(G)
%CHECK_CONNECTED Singleton is connected; an empty or malformed graph is rejected.
G = cn.adjacency(G);
components = conncomp(graph(G));
connected = all(components == components(1));
end
