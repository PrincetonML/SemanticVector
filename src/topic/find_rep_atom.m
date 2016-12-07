function [rep_atomids, info] = find_rep_atom(atomids, Dictionary, opts)
% find some representative atoms for a set of atoms
% atomids: array of atom ids
% Dictionary: each column is an atom
% rep_atomids: the ids of atoms found
% opts: options
%   opts.nRep: number of representative atoms to return (default: 5)
%
%   opts.method: 'svd' 'robust_kmeans' 'count' 'sos' (default: 'svd')
%   opts.nSVD: rank of svd (default: 5)
%   opts.contrast_atomids: a set of common atom ids; used in method 'svd'
%   opts.unique: if set >0, use unique atom ids (default: not set)
% 
%   opts.n_weight_paras: for 'sos' weight the atoms from the first few paragraphs
%   opts.para_weight: for 'sos' the weight for the first few paragraphs
%
% info: additional info about the output
%   info.count: number of times of an atom appearing when opts.method = 'count'

% parse options
if ~exist('opts', 'var')
    opts = [];
end

if isfield(opts, 'method')
    method = opts.method;
else
    method = 'svd'; %'sos'; % 'svd'; % default
end
if isfield(opts, 'nSVD')
    nSVD = opts.nSVD;
else
    nSVD = 5; % default
end

if isfield(opts, 'nRep')
    nRep = opts.nRep;
else
    nRep = 5; % default
end

if isfield(opts, 'unique') && opts.unique > 0
    atomids = unique(atomids);
end

if isfield(opts, 'n_weight_paras')
    n_weight_paras = opts.n_weight_paras;
else
    n_weight_paras = 1; % default
end

if isfield(opts, 'para_weight')
    para_weight = opts.para_weight;
else
    para_weight = 1.0; % default
end

% compute
info = [];
if isempty(atomids)
    rep_atomids = [];
    return;
end

if strcmp(method, 'svd') % svd
    if (nSVD > length(atomids))
        rep_atomids = atomids;
        return;
    end
    [U, ~, ~] = svds(Dictionary(:, atomids), nSVD);
    sim = sum((U'*Dictionary).^2);
    if isfield(opts, 'contrast_atomids')
        [Uc, ~, ~] = svds(Dictionary(:, opts.contrast_atomids), nSVD);
        sim = sim - sum((Uc'*Dictionary).^2); % contrast
    end
    [~, sid] = sort(sim, 'descend');
    rep_atomids = sid(1:nRep);
elseif strcmp(method, 'robust_kmeans') % robust_kmeans
    rep_atomids = robust_kmeans(Dictionary(:, atomids), Dictionary(:, atomids), nRep);
elseif strcmp(method, 'count') % count
    uid = unique(atomids);
    ins = histc(atomids, uid);
    [sval, sid] = sort(ins, 'descend');
    k = min(nRep, length(sid));
    rep_atomids = uid(sid(1:k));
    info.count = sval(1:k);
elseif strcmp(method, 'sos') % sos
    lAtom = length(atomids);
    weight = ones(lAtom, 1); 
    weight(1:min(n_weight_paras, lAtom)) = para_weight;

    WD = Dictionary(:, atomids) * diag(weight);
    sim = sum((WD'*Dictionary).^2);    
    if isfield(opts, 'contrast_atomids')
        rD = Dictionary(:, opts.contrast_atomids);
        sim = sim - sum((rD'*Dictionary).^2); % contrast
    end
    [~, sid] = sort(sim, 'descend');
    rep_atomids = sid(1:nRep);
else
    fprintf('unrecognized method %s\n', method);
end


