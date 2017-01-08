#!/bin/bash

# get the GloVe package by running the following command
mkdir external_tools
cd external_tools
git clone https://github.com/stanfordnlp/GloVe 
make
cd ..

# download text8 data
CORPUS=../data/text8 
if [ ! -e $CORPUS ]; then
wget http://mattmahoney.net/dc/text8.zip
unzip text8.zip -d $DATADIR
rm text8.zip
fi

# set up smallbox-2.1 for dictionary learning 
cd src/directory
mkdir tools
cd tools
wget -c https://code.soundsoftware.ac.uk/attachments/download/607/smallbox-2.1.zip
unzip smallbox-2.1.zip
cd smallbox-2.1
matlab -r "SMALLboxSetup"
cd ../../../..

# download needed data for learning dictionary on window vectors 
cd data
wget https://www.dropbox.com/s/abrpkdvljjplbte/enwiki_vocab.txt?dl=0 
wget -c https://www.dropbox.com/s/0bs5oohqwhesc4a/enwiki_sq_vectors.bin?dl=0
wget -c https://www.dropbox.com/s/puus99m7xgw75sj/poliblogs2008_para.mat?dl=0
cd ..
