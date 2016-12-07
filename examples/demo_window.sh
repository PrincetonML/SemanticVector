#!/bin/bash

# download needed data
cd ../data
wget https://www.dropbox.com/s/abrpkdvljjplbte/enwiki_vocab.txt?dl=0 
wget -c https://www.dropbox.com/s/0bs5oohqwhesc4a/enwiki_sq_vectors.bin?dl=0
wget -c https://www.dropbox.com/s/puus99m7xgw75sj/poliblogs2008_para.mat?dl=0
cd ../examples

# learn dictionary on window vectors (here each window vector is the weighted average of the word vectors in a paragraph)
matlab -nodisplay -nodesktop -nojvm -nosplash < learn_window_dictionary.m 1>&2 
