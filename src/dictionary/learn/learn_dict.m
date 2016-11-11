function [Dictionary, representation, info] = learn_dict(words, WordVector, opts)
% Learn a dictionary for a set of word vectors
% words: a cell array containing the vocabulary
% WordVector: each column is a word vector
% opts: options
%   opts.nCopy: number of dictionaries learned for merging (default: 5)
%   opts.nAtoms: number of atoms in each dictionary before merging (default: 2000)
%   opts.nSparsity: sparsity (default: 5)
%   opts.nStep: number of iterations in learning the dictionary (default:
%   25)
%   
%   opts.threshold_merge: if the inner product between two atoms is above this then 
%      count them as one atom
%   opts.threshold_drop: if the inner product between two atoms is above this then
%      count them as neighbors
%   opts.occur: keep an atom if it has more than this number of neighbors
%   opts.ncommon: remove the top ncommon atoms that appear most often
%   opts.output_info: if > 0, compute the corr and corr_words (default: not set)

% parse options
if ~exist('opts', 'var')
    opts = [];
end
if isfield(opts, 'nCopy')
    nCopy = opts.nCopy;
else
    nCopy = 5; % default value
end
if isfield(opts, 'nAtoms')
    nAtoms = opts.nAtoms;
else
    nAtoms = 2000; % default value
end
if isfield(opts, 'nSparsity')
    nSparsity = opts.nSparsity;
else
    nSparsity = 5; % default value
end
if isfield(opts, 'nStep')
    nStep = opts.nStep;
else
    nStep = 25; % default value
end

if isfield(opts, 'threshold_merge')
    threshold_merge = opts.threshold_merge;
else
    threshold_merge = 0.85; % default value
end
if isfield(opts, 'threshold_drop')
    threshold_drop = opts.threshold_drop;
else
    threshold_drop = 0.2; % default value
end
if isfield(opts, 'occur')
    occur = opts.occur;
else
    occur = 3; % default value
end
if isfield(opts, 'ncommon')
    ncommon = opts.ncommon;
else
    ncommon = 25; % default value
end

% get dictionaries
for i = 1:nCopy
    sample_id = randsample(size(WordVector,2), nAtoms); 
    initDict = normc(WordVector(:, sample_id));
    DL = semvec_DL(WordVector, nAtoms, nSparsity, nStep, initDict);
    dictionaries(i).dict = DL.D;
end

% merge dictionaries
Dictionary = merge_dictionaries( dictionaries, threshold_merge, threshold_drop, occur );
fprintf('number of atoms left after merging: %d\n', size(Dictionary, 2));
[representation,~]=get_sparse_rep(Dictionary, WordVector, nSparsity);

% prune bad atoms from dictionaries
nnz_rep = zeros(size(representation,1),1);
for i = 1:size(representation,1)
    nnz_rep(i) = nnz(representation(i,:));
end
[~, sid] = sort(nnz_rep, 'descend');
if length(sid) < ncommon
    commonones = sid(1:floor(length(sid)/2));
else
    commonones = sid(1:ncommon);
end
commonid = ismember(1:size(Dictionary, 2), commonones);
badones = find_bad_atoms(Dictionary, normc(WordVector));
badind = ismember(1:size(Dictionary, 2), badones);
temp = Dictionary;
Dictionary =  Dictionary(:,~badind & ~commonid);
fprintf('number of atoms left after pruning bad atoms: %d\n', size(Dictionary, 2));
if size(Dictionary, 2) < 1
    Dictionary = temp;
    fprintf('restore the dictionary before pruning\n');
end

% recompute representation
[representation,~]=get_sparse_rep(Dictionary, WordVector, nSparsity);

% if needed, compute corr_words corr
if isfield(opts, 'output_info') && opts.output_info > 0
	info.dictionaries = dictionaries;
	
    nNN = 100;
    info.corr=zeros(nNN,size(Dictionary,2));
    info.corr_words = cell(nNN,size(Dictionary,2));
    inn = (normc(WordVector))'*Dictionary;
    for i = 1:size(Dictionary,2)  
        [sval,sid]=sort(inn(:, i),'descend'); 
        info.corr(:,i) = sval(1:nNN); 
        info.corr_words(:,i)=words(sid(1:nNN)); 
    end
else
    info = [];
end
