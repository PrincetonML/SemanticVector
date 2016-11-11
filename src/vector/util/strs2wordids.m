function wordids = strs2wordids(strs, vocab)
%Output the indices of the words in the strings. Output -1 if not in the
%vocabulary.
% INPUT
% strs: a cell array ,where each cell is a string with multiple words; or
% just a string
% vocab: a cell array containing the vocabulary
% OUTPUT
% wordids: when strs is a cell array, wordids is a cell array, where wordids{i} contains an array consisting of the
%    indices for the string in strs{i}; if a word is not in the vocab,
%    return -1. When strs is one string, wordids is an array.

vocab_Map = containers.Map(vocab, 1:length(vocab));

if iscell(strs)
    wordids = cell(length(strs), 1);
    for i = 1:length(strs)
        words = strsplit(clean_str(strs{i}));
        wordids{i} = words_id_from_map(words, vocab_Map);
    end
else
    wordids = words_id_from_map(strsplit(clean_str(strs)), vocab_Map);
end
end % function

function cleaned = clean_str(raw)
% raw: a cell of strings
cleaned = lower(raw);
end

function ids = words_id_from_map(words_list, vocab_Map)
ids = zeros(length(words_list), 1);
for i = 1:length(words_list)
    if ~vocab_Map.isKey(words_list{i})
        ids(i) = -1;
    else
        ids(i) = vocab_Map(words_list{i});
    end
end

end