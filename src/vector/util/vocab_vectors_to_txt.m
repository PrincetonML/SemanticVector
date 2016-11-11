% function vocab_vectors_to_txt(vocab_file, vector_file, vector_size, output_txt_file)
% read vocab_file and vector_file, output the words and vectors to
% output_txt_file

% INPUT:
%  vocab_file: the name of the vocabulary file
%  vector_file: the name of the vector file.
%  vector_size: the dimension of the vectors.
%  output_txt_file: the name of the output txt file. Each line contains the
%  word and then the vector
% OPTIONAL INPUT:
%  max_words: maximum number of words to output 

function vocab_vectors_to_txt(vocab_file, vector_file, vector_size, output_txt_file, max_words)

[vocab, vectors] = read_vocab_vectors(vocab_file, vector_file, vector_size);
if nargin < 5
    max_words = length(vocab);
end

f = fopen(output_txt_file, 'w');
for i = 1:min(length(vocab), max_words)
    fprintf(f, '%s ', vocab{i});
    for j = 1:vector_size
        fprintf(f, '%f ', vectors(j, i));
    end
    fprintf(f, '\n');
end
fclose(f);
end