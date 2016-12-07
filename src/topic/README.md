This folder contains the code for finiding topic vectors for windows/paragraphs/documents.



The code is separated into two parts:

1. The topic vectors (atoms in a given dictionary) are given, and the goal is to find the representative atoms for a document and their coefficients, using robust_kmeans method.

The main entry for this part is the function:
  [doc_rep_atomids, doc_info, para_rep_atomids, para_info] = find_rep_atom_for_doc(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts)
The inputs are 
  doc_para_wordids: a cell array, doc_para_wordids{i} is the word ids for the  i-th para in the document
  Dictionary: each column is an atom
  WordVector: i-th column is the vector for the i-th word in the vocabulary
  para_opts, doc_opts: options for handling the paragraphs and the document; see the function file for the details.
The outputs are
  doc_atomids: the ids of the representative atoms for the document
  para_rep_atomids: a cell array, para_rep_atomids{i} contains the ids of the representative atoms for the i-th paragraph
  doc_info, para_info: additional output info for the paragraphs and the document; see the function file for the details.

This main function uses functions: 
  1) find_repr_atom_for_para: use robust_kmeans method to find representative atoms for paragraph 
    This function uses: find_atom_for_para, prune_atom_for_para, find_rep_atom
	(1) find_atom_for_para: find atoms for a paragraph
	(2) prune_atom_for_para: remove some not so useful atoms
	(3) find_rep_atom: see below
  2) find_rep_atom: given a set of atoms, pool them to find the representative atoms

This part also includes some utility functions:
  1) get_contrast_atomids: find the atoms in some paragraphs, so as to find out which ones are frequent. This functions uses find_atom_for_para, and the common atoms and their frequencies will be used in prune_atom_for_para and find_rep_atom. 
  2) math/robust_kmeans: our implementation of kmeans which removes some outliers. The other functions in math/ are for robust_kmeans.
  3) display/: includes some functions for displaying the information.

2. Given word vectors and a set of sequences of words (windows/paragraphs), learn the topic vectors (also called atoms in a dictionary) using the sparse coding method. 

The main entry for this part is the function: 
  [Dictionary, representation, info] = learn_atom_for_window(window_wordids, WordVector, words, opts)
The inputs are:
  window_wordids: a cell array, window_wordids{i} is an array containing the word ids in the window
  words: the vocabulary
  WordVector: the i-th column is a vector for the i-th word
  opts: options; see the function file for details.
The outputs are:
  Dictionary: each column is an atom
  representation: the i-th column is the representation coefficients for the i-th window
  info: additional output information; see the function file for details.
  
This main function uses functions: 
  1) get_win_vector: compute a vector for a sequence of words (a window), using weighted average.
  2) learn_dict: given the vectors, learn a dictionary (learn multiple copies, merge them, and prune bad atoms). This is in ../dictioinary/learn/
  
This part also includes the function
  coeff = win_dict_rep(wordids, WordVector, win_dict, opts)
This functions compute the representation for a window/paragraph of words. 
The inputs are: 
  wordids: an array, the ids of the words in the window
  WordVector: word vectors  
  win_dict: each column is an atom
  opts: the options; see the function file for details
The outputs are:
  coeff: the coefficients of the atoms
It uses functions: 
  1) get_win_vector: compute a vector for a sequence of words (a window), using weighted average.
  2) get_sparse_rep: given a vector and a dictionary, learn the sparse representation. This is in ../dictioinary/learn/
  
