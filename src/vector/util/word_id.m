function id=word_id(word, vocab_list)

id=find(strcmp(word, vocab_list));
if isempty(id)
    id = -1;
end