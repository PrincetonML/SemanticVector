function win_vector = get_win_vector(wordids, WordVector, opts)
%Compute the weighted average of the vectors in the window
% wordids: an array, the ids of the words in the window
% opts: options
%  opts.word_weights: weights for the words. If not set, use all one.

win_vector = zeros(size(WordVector, 1), 1);
wids = clean_wordids(wordids); 
if length(wids) < 1
    fprintf('Warning in get_win_vector: no words after cleaning %d words; return 0 vector\n', length(wordids));
    display(wordids);
    return;
end

if isfield(opts, 'word_weights')
    win_vector = WordVector(:, wids) * opts.word_weights(wids)/ (1 + length(wids));
else
    win_vector = mean(WordVector(:, wids), 2);
end
end % function

function twids = clean_wordids(wids)
%Clean the word ids: remove -1, remove too frequent words (<100)
nTop = 0;%100;
twids = wids( wids > nTop );
if isempty(twids)
    fprintf('Warning: no words after cleaning top %d words, so retain the first in-vocab word\n', nTop);
    twids = wids( wids > 0 );
    if isempty(twids)
        fprintf('Warning: no in-vocab words\n');
    else
        twids = twids(1);
    end
end
end