#!/bin/bash

# learn dictionary on window vectors (here each window vector is the weighted average of the word vectors in a paragraph)
matlab -nodisplay -nodesktop -nojvm -nosplash < learn_window_dictionary.m 1>&2 
