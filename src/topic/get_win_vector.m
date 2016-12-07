function win_vector = get_win_vector(wordids, WordVector, opts)
%Compute the weighted average of the vectors in the window
% wordids: an array, the ids of the words in the window (-1 means out-of-vocabulary words)
% opts: options
%  opts.word_weights: weights for the words. If not set, use all one.
%  opts.nTop: remove word ids <= nTop

win_vector = zeros(size(WordVector, 1), 1);
wids = clean_wordids(wordids, opts); 
if length(wids) < 1
    fprintf('Warning in get_win_vector: no words after cleaning %d words; return 0 vector\n', length(wordids));
    display(wordids);
    return;
end

if exist('opts', 'var') && isfield(opts, 'word_weights')
    win_vector = WordVector(:, wids) * opts.word_weights(wids)/ (1 + length(wids));
else
    win_vector = mean(WordVector(:, wids), 2);
end
end % function

function twids = clean_wordids(wids, opts)
%Clean the word ids: remove -1, remove too frequent words (<100)
if exist('opts', 'var') && isfield(opts, 'nTop')
    nTop = opts.nTop;
else
    nTop = 100;
end
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