# SemanticVector

This is the code for the paper ["A Latent Variable Model Approach to PMI-based Word Embeddings"](https://arxiv.org/abs/1502.03520) and the paper ["Linear Algebraic Structure of Word Senses, with Applications to Polysemy"](https://arxiv.org/abs/1601.03764).

## Get Started
After cloning the code, run

```
	./setup.sh
	cd examples
	./demo_vector.sh
	./demo_dictionary.sh
	./demo_window.sh
```

The script setup.sh will download data and external tools for the code. The three demo scripts are for three parts of the code. See the following for details.

## Directories:
1. data: contains some example test set
2. examples: contains demo.sh that shows how to use the code
3. src: contains the code. It has sub-directories: vector, dictionary, topic. These are explained below.


## src/vector:

### Usage
 
* Make sure that the GloVe package is in external_tools (if setup.sh is run, it should have downloaded it). If not, run the following command:

```
    mkdir external_tools
	cd external_tools
    git clone https://github.com/stanfordnlp/GloVe 
	make
```

* put the raw corpus in the data directory, preprocess it. We used wikifil.pl provided by Matt Mahoney, at the end of [this page](http://mattmahoney.net/dc/textdata). Example:

```
    perl wikifil.pl enwiki_raw_corpus > enwiki
```

An example preprocessed small corpus text8 is downloaded for the demo in setup.sh.
	
* change the variable CORPUS in the script example/demo_vector.sh to your preprocessed corpus

* cd into the example directory and run

```
    ./demo_vector.sh
```	

The script will make the programs, construct the vocabulary, compute and shuffle the co-occurrence, and finally construct the word vectors using the algorithm in [our paper](http://arxiv.org/abs/1502.03520).  The codes for computing the vocabulary and the co-occurrence are borrowed from [GloVe](http://nlp.stanford.edu/projects/glove/).
The constructed vocabulary is saved in vector_result/text8_vocab.txt, and the constructed vectors are saved in vector_result/text8_rw_vectors.bin.
	
* In Matlab, use the script in vector/util/read_vocab_vectors.m to load the vocabulary and word vectors (binary format) from the files: 

```
    [vocab, vectors] = read_vocab_vectors(vocab_file, vector_file, vector_size);
```

* In Matlab, use the script in vector/eval/evaluate_on_GOOGLE.m to evaluate the word vectors on the GOOGEL testbed.

### More info

Run ./randwalk in the directory vector to get help information about its options. Similarly, for the GloVe package, run ./vocab_count (or ./cooccur ./shuffle) to get help about the options. 
Frequently used options:

* ./vocab_count

    -min-count <int>: Lower limit such that words which occur fewer than <int> times are discarded.
	
* ./cooccur 

    -memory <float>: Soft limit for memory consumption, in GB -- based on simple heuristic, so not extremely accurate; default 4.0
	
    -window-size <int>: Number of context words to the left (and to the right, if symmetric = 1); default 15
	
* ./randwalk

    -iter <int>: Number of training iterations; default 25 
	
    -vector-size <int>: Dimension of word vector representations; default 50
	
    -binary <int>: Save output in binary format (0: text, 1: binary, 2: both); default 1
	
    Note that the Matlab script provided is only for loading word vectors in binary format.
    
	
	
## src/directory

### Usage 

* Make sure the sparse coding package smallbox-2.1 is downloaded and installed (If setup.sh is run, this should have been installed). 
 
  If not, make a directory src/directory/tools/
   
  download smallbox-2.1.zip from https://code.soundsoftware.ac.uk/projects/smallbox/files
  
  unzip it in dictionary/tools/ and install it following the instructions in its README file.

* cd into the example directory and run

```
    ./demo_dictionary.sh
```	

The script runs learn_rw_dictionary.m in Matlab.

Note: first need to construct the word vectors; see above

Read and change the parameters in line 11 to 19 in the script to satisfy you needs. (the current parameters are for the Wikipedia corpus consisting of about 3G tokens) 

The constructed dictionary will be saved in mat format in dictionary_result. The mat file contains the following variables:

* Dictionary: each column is an atom.

* words: cell array, the vocabulary.

* WordVector: each column is a word vector; the i0th column is the vector for words{i}.

* representation: the representation of the word vectors, that is, WordVector is approximately Dictionary times representation.

* corr_words: cell matrix. corr_words{:, i} are the 100 nearest words to the i-th atom.

* corr: cell matrix. corr{j,i} is the corresonding inner product between j-th nearest word and the i-th atom.
	
	

## src/topic

### Usage 

* Make sure that the needed data is downloaded (see setup.sh)

* cd into the example directory and run

```
    ./demo_window.sh
```	

This script downloads the needed data (about 500MB) and runs learn_window_dictionary.m. It computes window vectors (each window vector is the weighted average of the word vectors in a paragraph), and computes a dictionary on these window vectors. The atoms in this dictionary can be viewed as topic vectors.

See the README file in src/topic/ for more information.