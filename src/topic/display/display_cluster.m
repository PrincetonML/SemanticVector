function display_cluster(cluster_wordids, words)

for i = 1:length(cluster_wordids)
    fprintf('\t\tCluster %d ', i);
    for j = 1:length(cluster_wordids{i})
        fprintf('%s ', words{cluster_wordids{i}(j)});
    end
    fprintf('\n');    
end
end