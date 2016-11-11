function ids = words_id(words_list, vocab)

vocab_Map = containers.Map(vocab, 1:length(vocab));
ids = zeros(length(words_list), 1);
for i = 1:length(words_list)
    if ~vocab_Map.isKey(words_list{i})
        ids(i) = -1;
    else
        ids(i) = vocab_Map(words_list{i});
    end
end

end