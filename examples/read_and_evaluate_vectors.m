%% init
pwdir = pwd();
cd ../src
INIT
eval(sprintf('cd %s', pwdir));

%% load data
vocab_file = './vector_result/text8_vocab.txt';
vector_file = './vector_result/text8_rw_vectors.bin';
vector_size = 300;
[vocab, vectors] = read_vocab_vectors(vocab_file, vector_file, vector_size);

%% evaluate
testbed_dir = '../data/testbeds/GOOGLE';
evaluate_on_GOOGLE(vocab, vectors, testbed_dir);

%% exit
exit;