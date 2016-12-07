function display_center(centers, WordVector, words)
    for k = 1:size(centers, 2)
        inner = normc(WordVector)'*centers(:, k); 
        [~, sid] = sort(inner, 'descend');
        fprintf('\t\tCenter %d ', k);
        for kk = 1:10
            fprintf('%s ', words{sid(kk)});
        end
        fprintf('\n');
    end
end