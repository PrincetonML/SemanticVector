function coeffs = win_dict_test_example(win_dict_file, win_wordids, opts)
%Output the representation for a few windows
% win_wordids: a cell, win_wordids{i} contains the word ids for the i-th
% window
% opts: options
%   opts.word_weights: word_weights(i) is the weight for the word with id i
%   (default: all 1)
%   opts.nSparsity: sparsity in the representation (default 5)
%

load(win_dict_file, 'words', 'WordVector', 'win_dict', 'corr_words');

coeffs = cell(size(win_wordids));
for i = 1:length(win_wordids)
    wordids = win_wordids{i};
    coeffs{i} = win_dict_rep(wordids, WordVector, win_dict, opts);    
    display(strjoin(words(wordids(wordids>0))));
    display_win_dict_rep(coeffs{i}, corr_words);    
end

end % function