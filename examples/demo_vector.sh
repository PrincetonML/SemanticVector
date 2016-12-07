#!/bin/bash

TOOL_SRC_DIR=../external_tools/GloVe/src
TOOL_BULID_DIR=../external_tools/GloVe/build
PROGDIR=../src/vector
DATADIR=../data
RESULTDIR=./vector_result
CORPUS=$DATADIR/text8 # need to change this to your corpus
VOCAB_FILE=$RESULTDIR/text8_vocab.txt
COOCCURRENCE_FILE=$RESULTDIR/text8_cooccurrence.bin
COOCCURRENCE_SHUF_FILE=$RESULTDIR/text8_cooccurrence.shuf.bin
SAVE_FILE=$RESULTDIR/text8_rw_vectors
VERBOSE=2
MEMORY=40.0
VOCAB_MIN_COUNT=1000
VECTOR_SIZE=300
MAX_ITER=50
WINDOW_SIZE=10
BINARY=1
NUM_THREADS=16
X_MAX=100

# download data
if [ ! -e $CORPUS ]; then
wget http://mattmahoney.net/dc/text8.zip
unzip text8.zip -d $DATADIR
rm text8.zip
fi

# make the program
make -C $PROGDIR
make -C $TOOL_SRC_DIR

# learn and evaluate word vectors
mkdir $RESULTDIR
$TOOL_BULID_DIR/vocab_count -min-count $VOCAB_MIN_COUNT -verbose $VERBOSE < $CORPUS > $VOCAB_FILE
if [[ $? -eq 0 ]]
  then
  $TOOL_BULID_DIR/cooccur -memory $MEMORY -vocab-file $VOCAB_FILE -verbose $VERBOSE -window-size $WINDOW_SIZE < $CORPUS > $COOCCURRENCE_FILE 
  if [[ $? -eq 0 ]]
  then
    $TOOL_BULID_DIR/shuffle -memory $MEMORY -verbose $VERBOSE < $COOCCURRENCE_FILE > $COOCCURRENCE_SHUF_FILE
    if [[ $? -eq 0 ]]
    then
      $PROGDIR/randwalk -save-file $SAVE_FILE -threads $NUM_THREADS -input-file $COOCCURRENCE_SHUF_FILE -x-max $X_MAX -iter $MAX_ITER -vector-size $VECTOR_SIZE -binary $BINARY -vocab-file $VOCAB_FILE -verbose $VERBOSE 
      if [[ $? -eq 0 ]]
      then
        matlab -nodisplay -nodesktop -nojvm -nosplash < read_and_evaluate_vectors.m 1>&2 
      fi
    fi
  fi
fi

