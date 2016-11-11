%the script for building the dictionaries, and then merge them, prune bad
%atoms to get the final dictionary

%% init
pwdir = pwd();
cd ../src
INIT
eval(sprintf('cd %s', pwdir));

% parameters
vocab_file = './vector_result/text8_vocab.txt';
vector_file = './vector_result/text8_rw_vectors.bin';
vector_size = 300;
[words, WordVector] = read_vocab_vectors(vocab_file, vector_file, vector_size);

% learn
opts.output_info = 1; % use default values for the parameters 
[Dictionary, representation, info] = learn_dict(words, WordVector, opts);
corr = info.corr;
corr_words = info.corr_words;

% save
mkdir('dictionary_result');
save_file = 'dictionary_result/text8_rw_dict_merge_pruned.mat'; 
save(save_file, 'words', 'WordVector', 'Dictionary', 'representation', 'corr', 'corr_words', '-v7.3'); 

% exit
exit;