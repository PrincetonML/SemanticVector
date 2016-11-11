% function [ind1,ind2,ind3,ind4]=get_questions(vocab,ques_file)
%  get the index of the tokens in the question file ques_file in the
%   vacabulary vocab
%  use the function words_id
%
% INPUT:
%  words: a cell of tokens
%  ques_file: filename contianing questions. Each line contains four tokens.
%
% OUTPUT:
%  ind1/ind2/ind3/ind4: the index of the first/second/third/fourth token in
%  each line; -1 if not in the vocab

function [ind1,ind2,ind3,ind4]=get_questions(vocab,ques_file)

fid=fopen(ques_file);
temp=textscan(fid,'%s%s%s%s');
fclose(fid);

ind1 = words_id(temp{1}, vocab); %indices of first word in analogy
ind2 = words_id(temp{2}, vocab); %indices of second word in analogy
ind3 = words_id(temp{3}, vocab); %indices of third word in analogy
ind4 = words_id(temp{4}, vocab); %indices of answer word in analogy
end