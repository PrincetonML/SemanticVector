
function normalized_greedy_matching(V1, V2, pids, cids)
% each column of V1 or V2 is a vector
nV1 = normc(V1);
for i = 1:size(V1, 2) % normc will normalize all 0 column to all 1; not desired
    if norm(V1(:,i)) < 1e-10
        nV1(:, i) = 0;
    end
end
nV2 = normc(V2);
for i = 1:size(V2, 2)
    if norm(V2(:,i)) < 1e-10
        nV2(:, i) = 0;
    end
end
inner = V1'*V2;
nInner = nV1'*nV2 + 1;
% fprintf('\tThe cos sim between the discourses in previous para and current para\n');
% display(inner)
[~, m1, m2] = bipartite_matching(nInner);
for i = 1:length(m1)
    fprintf('\t%d, %d, %f, %f \n', pids(m1(i)), cids(m2(i)), ...
        nInner(m1(i), m2(i)) - 1, inner(m1(i), m2(i)));
end
end % function