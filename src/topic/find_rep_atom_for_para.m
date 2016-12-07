function [rep_atomids, info] = find_rep_atom_for_para(para_wordids, Dictionary, WordVector, opts)
% Find representative atoms for a paragraph, prune the common atoms, and finally find represenative among the
% union
% para_wordids: an array of word ids; can have -1 for words not in the
% vocabulary
% opts: options
%  opts.algo: 'kmeans' 'dict_atoms'
%
% if opts.algo=='dict_atoms'
%   opts.dict_atoms_weight_para: the weight parameter (default not set); if
%   set, also need opts.freq 
%   opts.freq: the frequency of the words
%   opts.n_weight_words: the first few words in each window will be weighted
%   opts.word_weight: the weight for the few words (positive)
% if opts.algo=='dir_prior'
%   besids the options for 'dict_atoms', we also have
%   opts.dir_prior: the Dirichlet prior parameters
%   opts.grad_step_size: step size when using gradient to solve the problem
%   (default 0.01)
%   opts.grad_step_num: number of gradient steps (default 100)
%   opts.recovery_init: if >0, use the result from old method as init
%
% if opts.algo=='kmeans'
% opts include the opts for find_atom_for_para and prune_atom_for_para:
%  opts.nAtom: number of atoms for each window (default: 5)
%  opts.atom_freq: an array containing the frequency of the atoms (can be unnormalized)
%  opts.select_nAtom: if opts.atom_freq is set, keep at most
%    opts.select_nAtom atoms after filtering (default: 3).
%  opts.n_weight_words: the first few words in each window will be weighted
%  (default: 1.0)
%  opts.word_weight: the weight for the few words (positive) (default: 1.0)
%  opts.keep_ratio: keep a few points in the cluster; see robust_kmeans
%  (default: not set)
%
% opts also include the opts for find_rep_atom, especially the following:
%  opts.nSVD: rank of svd (default: 5)
%  opts.contrast_atomids: a set of common atom ids; used in method 'svd'
%  opts.nRep: number of representative atoms to return (default: 3)
%
% opts also include how to output info
%  opts.reassign: if set > 0, then reassign the words to the atoms to get
%  new clusters (default: 1). only effective for opts.algo=='kmeans'
%
% info: additional output info
%  info.atom_word_ids: the ids of the words assigned to the cluster of the atom
%  info.atom_coeff: the coefficients for the atoms
%  info.cluster_centroids: the average of the word vectors assigned to the
%  atom

if ~exist('opts', 'var')
    opts = [];
end

if isfield(opts, 'algo')
    algo = opts.algo;
else
    algo = 'kmeans'; 
end

% swtich according to the method
if strcmp(algo, 'dict_atoms')
    [rep_atomids, info] = find_rep_atom_for_para_by_dict_atom(para_wordids, Dictionary, WordVector, opts);
    return;
elseif strcmp(algo, 'kmeans')
    [rep_atomids, info] = find_rep_atom_for_para_by_robust_kmeans(para_wordids, Dictionary, WordVector, opts);
    return;    
elseif strcmp(algo, 'dir_prior')
    [rep_atomids, info] = find_rep_atom_for_para_by_dir_prior(para_wordids, Dictionary, WordVector, opts);
    return;
else
    fprintf('Error: unrecognized algo option %s\n', algo);
    rep_atomids = [];
    info = [];
    return;    
end
end % function

function [rep_atomids, info] = find_rep_atom_for_para_by_robust_kmeans(para_wordids, Dictionary, WordVector, opts)
% parse options
if isfield(opts, 'reassign')
    reassign = opts.reassign;
else
    reassign = 0; 
end

if length(para_wordids)  < 10 
    fprintf('Paragraph too short\n');
    rep_atomids = [];
    info = [];
    return;
end

% kmeans method
[para_atomids, para_atomid4word, kmeans_centers] = find_atom_for_para(para_wordids, Dictionary, WordVector, opts);
pruned_atomids = prune_atom_for_para(para_wordids, para_atomids, para_atomid4word, opts);
[rep_atomids, ~] = find_rep_atom(pruned_atomids, Dictionary, opts);

% info
info.atom_coeff = zeros(length(rep_atomids), 1);
info.atom_word_ids = cell(length(rep_atomids), 1);
info.cluster_centroids = zeros(size(WordVector,1), length(rep_atomids));
if reassign > 0
    para_wordids = para_wordids(para_wordids > 0);
    inner = Dictionary(:, rep_atomids)' * WordVector(:, para_wordids);
    [~, mid] = max(inner); 
    for i = 1:length(rep_atomids)
        info.atom_word_ids{i} = find(mid == i);
        info.atom_coeff(i) = length(info.atom_word_ids{i});
        if info.atom_coeff(i) > 0
            info.cluster_centroids(:, i) = mean(WordVector(:, info.atom_word_ids{i}), 2);
        end
    end
else
    for i = 1:length(rep_atomids)
        info.atom_word_ids{i} = para_wordids(para_atomid4word == rep_atomids(i));
        info.atom_coeff(i) = length(info.atom_word_ids{i});
        info.cluster_centroids(:, i) = mean(kmeans_centers(:, para_atomids == rep_atomids(i)), 2);
    end
end % reassign > 0
end % function

function [rep_atomids, info] = find_rep_atom_for_para_by_dict_atom(para_wordids, Dictionary, WordVector, opts)
%  opts.n_weight_words: the first few words in each window will be weighted
%  opts.word_weight: the weight for the few words (positive)

% parse options
if isfield(opts, 'nAtom')
    nAtom = opts.nAtom;
else
    nAtom = 5; % default
end

if isfield(opts, 'n_weight_words')
    n_weight_words = opts.n_weight_words;
else
    n_weight_words = 0; % default
end

if isfield(opts, 'word_weight')
    word_weight = opts.word_weight;
else
    word_weight = 1.0; % default
end

if length(para_wordids)  < 10 
    fprintf('Paragraph too short\n');
    rep_atomids = [];
    info = [];
    return;
end

% find representative atoms by sparse recovery
wordids = para_wordids(para_wordids > 100); % remove too frequent words
word_weights = ones(length(wordids), 1);
word_weights(1:min(n_weight_words, length(wordids))) = word_weight;
WV = WordVector(:, wordids) * diag(word_weights); % weighting the first few words
if isfield(opts, 'dict_atoms_weight_para') && isfield(opts, 'freq')  % downweight too frequent words      
    weights = opts.dict_atoms_weight_para ./ ...
        (opts.dict_atoms_weight_para + opts.freq(wordids)/sum(opts.freq));
    win_vecs = WV * weights / length(wordids);
else
    win_vecs = mean(WV, 2);
end
win_vecs  = normc(win_vecs);

[rep,~] = get_sparse_rep(Dictionary, win_vecs, nAtom);
[rep_atomids, ~] = find_rep_atom(find(rep), Dictionary, opts);

% get info
inner = Dictionary(:, rep_atomids)' * WordVector(:, wordids);
[~, mid] = max(inner); 

info.atom_coeff = zeros(length(rep_atomids), 1);
info.atom_word_ids = cell(length(rep_atomids), 1);
info.cluster_centroids = zeros(size(WordVector,1), length(rep_atomids));
for i = 1:length(rep_atomids)
    info.atom_word_ids{i} = wordids(mid == i);
    info.atom_coeff(i) = rep(rep_atomids(i));
    info.cluster_centroids(:, i) = mean(WordVector(:, info.atom_word_ids{i}), 2);
end
end % function

function [rep_atomids, info] = find_rep_atom_for_para_by_dir_prior(para_wordids, Dictionary, WordVector, opts)
%  opts.n_weight_words: the first few words in each window will be weighted
%  opts.word_weight: the weight for the few words (positive)
%  opts.dir_prior: a column vector, the prior parameter for the Dirichlet distribution over
%  the atoms
verbose = 2; 
if verbose >= 2 % debug
    fprintf('options in find_rep_atom_for_para_by_dir_prior\n');
    display(opts)
end

% parse options
if isfield(opts, 'nAtom')
    nAtom = opts.nAtom;
else
    nAtom = 5; % default
end

if isfield(opts, 'n_weight_words')
    n_weight_words = opts.n_weight_words;
else
    n_weight_words = 0; % default
end

if isfield(opts, 'word_weight')
    word_weight = opts.word_weight;
else
    word_weight = 1.0; % default
end

if isfield(opts, 'dir_prior')
    dir_prior = opts.dir_prior;
else
    dir_prior = ones(size(Dictionary,2), 1); % default: uniform prior
end

if isfield(opts, 'grad_step_size')
    grad_step_size = opts.grad_step_size;
else
    grad_step_size = 0.01; % default
end

if isfield(opts, 'grad_step_num')
    grad_step_num = opts.grad_step_num;
else
    grad_step_num = 100; % default
end

if isfield(opts, 'recovery_init')
    recovery_init = opts.recovery_init;
else
    recovery_init = 1; % default
end

if length(para_wordids)  < 10 
    fprintf('Paragraph too short\n');
    rep_atomids = [];
    info = [];
    return;
end

% get the weighted average of the word vectors in the paragraph
% wordids = para_wordids(para_wordids > 100); % remove too frequent words
wordids = para_wordids; % keep too frequent words and let them downweighted 
word_weights = ones(length(wordids), 1);
word_weights(1:min(n_weight_words, length(wordids))) = word_weight;
WV = WordVector(:, wordids) * diag(word_weights); % weighting the first few words
if isfield(opts, 'dict_atoms_weight_para') && isfield(opts, 'freq')  % downweight too frequent words      
    weights = opts.dict_atoms_weight_para ./ ...
        (opts.dict_atoms_weight_para + opts.freq(wordids)/sum(opts.freq));
    win_vecs = WV * weights / length(wordids);
else
    win_vecs = mean(WV, 2);
end
win_vecs  = win_vecs / size(WV, 2);

% get the MAP solution
% initialization 
if recovery_init
    [rep,~] = get_sparse_rep(Dictionary, win_vecs, nAtom);
    rep(rep <= 0) = 1/length(rep);  % prevent 0
else
    rep = ones(size(Dictionary, 2), 1);
end
rep = rep / sum(rep); 

a = Dictionary' * win_vecs;
for t = 1:grad_step_num
   grad = a + (dir_prior - 1) ./ rep; 
   rep = rep - grad_step_size * grad;
   
   rep(rep <= 0) = 1e-10/length(rep);  % prevent 0
   rep = rep / sum(rep); 
end
[~, sid] = sort(rep, 'descend');
rep_atomids = sid(1:min(length(sid), nAtom));

% get info
inner = Dictionary(:, rep_atomids)' * WordVector(:, wordids);
[~, mid] = max(inner); 

info.atom_coeff = zeros(length(rep_atomids), 1);
info.atom_word_ids = cell(length(rep_atomids), 1);
info.cluster_centroids = zeros(size(WordVector,1), length(rep_atomids));
for i = 1:length(rep_atomids)
    info.atom_word_ids{i} = wordids(mid == i);
    info.atom_coeff(i) = rep(rep_atomids(i));
    info.cluster_centroids(:, i) = mean(WordVector(:, info.atom_word_ids{i}), 2);
end
end % function