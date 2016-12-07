function [para_atomids, para_atomid4word, kmeans_centers] = find_atom_for_para(para_wordids, Dictionary, WordVector, opts)
% find atoms for a paragraph
% INPUT
% para_wordids: the array of word ids in a paragraph; can have word id -1 for out-of-vocabulary words
% Dictionary: columns are atoms
% WordVector: columns are word vectors
% opts: options
%  opts.method: 'robust_kmeans' (default: 'robust_kmeans')
%  opts.nAtom: number of atoms (default: 5) 
%  opts.minWordId: only consider words with id larger than this (default: 100)
%
%  opts.n_weight_words: the first few words will be weighted (default: 0)
%  opts.word_weight: the weight for the few words (positive) (default: 1.0)
%
%  opts.keep_ratio: keep a few points in the cluster; see robust_kmeans
% 
% OUTPUT
% para_atomids: an array of atom ids for the paragraph
% para_atomid4word: an array of atom ids, para_atomid4word(i)=j means
% atom j is active for word i (para_atomid4word(i) = -1, 
% if para_wordids(i) = -1 or para_wordids(i) is an outlier in robust kmeans)
% kmeans_centers: the centers in robust_kmeans

% parse options
if ~exist('opts', 'var')
    opts = [];
end

fprintf('options in find_atom_for_para\n');
display(opts)

if isfield(opts, 'method')
    method = opts.method;
else
    method = 'robust_kmeans'; % default
end

if isfield(opts, 'nAtom')
    nAtom = opts.nAtom;
else
    nAtom = 5; % default
end

if isfield(opts, 'minWordId')
    minWordId = opts.minWordId;
else
    minWordId = 100; % default
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

% compute
if strcmp(method, 'robust_kmeans')    
    id = (para_wordids > minWordId);
    in_vocab = para_wordids(id);
    if isempty(in_vocab)
        para_atomids = [];
        para_idx = [];
        kmeans_centers = [];
    else        
        fprintf('robust kmeans\n');
        if (word_weight < 1.0001 && word_weight > 0.9999)
            kmeans_opts.weight = [];
        else 
            kmeans_opts.weight = ones(length(in_vocab), 1);
            kmeans_opts.weight(1:min(length(in_vocab), n_weight_words)) = word_weight;
        end
        if isfield(opts, 'keep_ratio')
            kmeans_opts.keep_ratio = opts.keep_ratio; 
            fprintf('Use keep_ratio: %s\n', opts.keep_ratio);
        else
            % default: not set
        end
        [para_atomids, para_idx, kmeans_centers] = robust_kmeans(WordVector(:,in_vocab), Dictionary, nAtom, kmeans_opts);
    end    
    para_atomid4word = -1 * ones(length(para_wordids), 1);
    para_atomid4word(id) = para_idx; % here para_active_atomids(i)=j means word i assigned to para_atomids(j)
    pmap = (para_atomid4word > 0); 
    para_atomid4word(pmap) = para_atomids(para_atomid4word(pmap)); % here para_active_atomids(i)=j means word i assigned to the j-th atom
else
    fprintf('unrecognized find-atom method: %s \n', method);
end

