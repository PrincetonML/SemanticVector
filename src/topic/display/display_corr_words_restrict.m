function display_corr_words_restrict(atom, restrict_vocab, restrict_wordvec, K)
% Print the K correlated words among a restricted set of words for the discourse atom
% atom: vector for the discourse atom
% restrict_vocab: a restricted set of words
% restrict_wordvec: restrict_wordvec(:, i) is the word vector for
% restrict_vocab{i}
% K: number of words to print

inner = atom' * restrict_wordvec;
[~, sid] = sort(inner, 'descend');
K = min(K, length(sid));
show_words = restrict_vocab(sid(1:K));

fprintf('\t\tcorrelated words (restricted): ')
for k = 1:K
    fprintf('%s ', show_words{k});
end
fprintf('\n');