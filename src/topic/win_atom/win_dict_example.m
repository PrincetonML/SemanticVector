function win_dict_example(win_dict_file, nExample)
%Output some examples from the window/paragraph dictionary for eyeballing

if nargin < 2
    nExample = 10;
end

load(win_dict_file, 'para_wordids', 'words', 'win_rep', 'corr_words');

% output atom examples
atomids = 1:nExample;
display_win_dict_atom(atomids, corr_words);

% output window example
para_id = 1;
wordids = para_wordids{para_id};
wordids = wordids(wordids>0);
display(strjoin(words(wordids)));
display_win_dict_rep(win_rep(:, para_id), corr_words);

end % function