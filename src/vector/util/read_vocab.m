% function [vocab, counts]=read_vocab(vocab_file)
%  read the vocabulary words from file
% 
% INPUT
%  vocab_file: the name of the vocabulary file
% 
% OUTPUT
%  vocab: a cell array containing the words
%  counts: a cell array containing the numbers of occurrence for the words

function [vocab, counts]=read_vocab(vocab_file)
    fid = fopen(vocab_file, 'r');
    vocab = textscan(fid, '%s %f');
    fclose(fid);
	counts = vocab{2};
    vocab = vocab{1};
end