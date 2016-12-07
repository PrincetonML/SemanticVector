function display_corr_words(atomid, corr_words, K)
%Print the K correlated words for discourse with id atomid
% INPUT:
% corr_words: a cell array, (i,j)-th entry is the i-th correlated word for
%   j-th discourse
% dis_ids: an array
% K: number of words to print

fprintf('\t\tcorrelated words: ');
for k = 1:K
    fprintf('%s ', corr_words{k, atomid});
end
fprintf('\n');