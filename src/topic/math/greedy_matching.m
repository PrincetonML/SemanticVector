function greedy_matching(V1, V2, pids, cids)
% each column of V1 or V2 is a vector
inner = V1'*V2 + 1;
% fprintf('\tThe cos sim between the discourses in previous para and current para\n');
% display(inner)
[~, m1, m2] = bipartite_matching(inner);
for i = 1:length(m1)
    fprintf('\t%d, %d, %f\n', pids(m1(i)), cids(m2(i)), inner(m1(i), m2(i)) - 1);
end
end % function