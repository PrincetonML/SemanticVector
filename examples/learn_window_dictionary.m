%% data input
%  win_mat_file: mat file containing para_wordids. para_wordids{i} are an
%  array of word indices in paragraph i.
%  vocab_file: vocabulary file
%  vector_file: word vector file
%  vector_size: the vector dimension
win_mat_file = '../data/poliblogs2008_para.mat';
vocab_file = '../data/enwiki_vocab.txt';
vector_file = '../data/enwiki_sq_vectors.bin';
vector_size = 300;

%% opts: options
%  opts.nAtoms: number of atoms to learned (default 2000)
%  opts.nSparsity: number of atoms to represent each window (default 5)
%  opts.word_weights_para: a parameter for computing the word weights
%  opts.max_win: max size of the paragraph
%  opts.output_file: save the result to this file
opts.nAtoms = 2000;
opts.nSparsity = 5;
opts.word_weights_para = 10^(-3);
opts.max_win = 200;
mkdir('paragraph_result');
opts.output_file = 'paragraph_result/paragraph_dictionary.mat';

%% init
pwdir = pwd();
cd ../../src
INIT
eval(sprintf('cd %s', pwdir));
cd ..
addpath(fullfile(pwd(),'win_atom'))
eval(sprintf('cd %s', pwdir));

rng(1)

%% load data
[words, freq] = read_vocab(vocab_file);
[~, WordVector] = read_vocab_vectors(vocab_file, vector_file, vector_size);
load(win_mat_file, 'para_wordids');
opts.word_weights = get_word_weights(freq, opts.word_weights_para);

if isfield(opts, 'nWin') && opts.nWin < length(para_wordids)
    sids = randsample(length(para_wordids), opts.nWin);
    para_wordids = para_wordids(sids);
end
if isfield(opts, 'max_win') && opts.max_win > 0
    for i = 1:length(para_wordids)
        if length(para_wordids{i}) > opts.max_win
            para_wordids{i} = para_wordids{i}(1:opts.max_win);
        end
    end 
end

%% learn
[win_dict, win_rep, info] = learn_atom_for_window(para_wordids, WordVector, words, opts);

%% save
if isfield(opts, 'output_file')
    output_file = opts.output_file;
else
    output_file = 'win_atom.mat';
end
corr = info.corr;
corr_words = info.corr_words;
save(output_file, 'para_wordids', 'words', 'freq', 'WordVector', 'opts', ... % input
     'win_dict', 'win_rep', 'corr', 'corr_words', ...  % output
     '-v7.3'); % large data file 

