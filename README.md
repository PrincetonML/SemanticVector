1. data: contains some example test set
2. examples: contains demo.sh that shows how to use the code
3. src: contains the code. It has sub-directories: vector and dictionary

src/vector:
1) Usage 
[0] get the GloVe package by running the following command:
    mkdir external_tools
	cd external_tools
    git clone https://github.com/stanfordnlp/GloVe 
[1] put the raw corpus in the data directory, preprocess it. (We used wikifil.pl provided by Matt Mahoney.)
    Example:
    perl wikifil.pl enwiki_raw_corpus > enwiki
    An example preprocessed small corpus text8 is provided for the demo.
[2] change the variable CORPUS in the script example/demo.sh to your preprocessed corpus
[3] cd into the example directory vector and run
    ./demo.sh
    The script will make the programs, construct the vocabulary, compute and shuffle the co-occurrence, and finally construct the word vectors using the algorithm in our paper (http://arxiv.org/abs/1502.03520).  The codes for computing the vocabulary and the co-occurrence are borrowed from GloVe (http://nlp.stanford.edu/projects/glove/).
    The constructed vocabulary is saved in vector_result/text8_vocab.txt, and the constructed vectors are saved in vector_result/text8_rw_vectors.bin.
[4] In Matlab, use the script in vector/util/read_vocab_vectors.m to load the vocabulary and word vectors (binary format) from the files: 
    [vocab, vectors] = read_vocab_vectors(vocab_file, vector_file, vector_size);
[5] In Matlab, use the script in vector/eval/evaluate_on_GOOGLE.m to evaluate the word vectors on the GOOGEL testbed.
2) More info
Run ./randwalk in the directory vector to get help information about its options. Similarly, for the GloVe package, run ./vocab_count (or ./cooccur ./shuffle) to get help about the options. 
Frequently used options:
[0] ./vocab_count
    -min-count <int>: Lower limit such that words which occur fewer than <int> times are discarded.
[1] ./cooccur 
    -memory <float>: Soft limit for memory consumption, in GB -- based on simple heuristic, so not extremely accurate; default 4.0
    -window-size <int>: Number of context words to the left (and to the right, if symmetric = 1); default 15
[2] ./randwalk
    -iter <int>: Number of training iterations; default 25 
    -vector-size <int>: Dimension of word vector representations; default 50
    -binary <int>: Save output in binary format (0: text, 1: binary, 2: both); default 1
    Note that the Matlab script provided is only for loading word vectors in binary format.
    
src/directory
1) Usage 
[0] make a directory src/directory/tools/
    download smallbox-2.1.zip from https://code.soundsoftware.ac.uk/projects/smallbox/files
    unzip it in dictionary/tools/ and install it following the instructions in its README file.
[1] In Matlab, run learn_rw_dictionary.m.
    Note: first need to construct the word vectors; see above
    Read and change the parameters in line 11 to 19 in the script to satisfy you needs. (the current parameters are for the Wikipedia corpus consisting of about 3G tokens) 
    The constructed dictionary will be saved in mat format in dictionary_result. The mat file contains the following variables:
    Dictionary: each column is an atom.
    words: cell array, the vocabulary.
    WordVector: each column is a word vector; the i0th column is the vector for words{i}.
    representation: the representation of the word vectors, that is, WordVector is approximately Dictionary * representation.
    corr_words: cell matrix. corr_words{:, i} are the 100 nearest words to the i-th atom.
    corr: cell matrix. corr{j,i} is the corresonding inner product between j-th nearest word and the i-th atom.