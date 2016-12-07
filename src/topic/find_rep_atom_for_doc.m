function [doc_rep_atomids, doc_info, para_rep_atomids, para_info] = find_rep_atom_for_doc(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts)
% Find representative atoms for a document
% INPUT
% doc_para_wordids: a cell array, doc_para_wordids{i} is the word ids for
% i-th para in the document
% Dictionary: each column is an atom
% WordVector: i-th column is the vector for the i-th word in the vocabulary
%
% doc_opts: options for finding representative atoms for the document
% (include the options in find_rep_atom)
%   doc_opts.doc_method: 'separate' 'share' (default: 'separate')
%   When doc_opts.doc_method =  'share', also include the following options:
%   doc_opts.nRep: #global atoms (default: 5)
%   doc_opts.update_iter: #iterations 
%   doc_opts.reg_weight: the regularization weight on associated_centers
%   (default: 1.0)
%
%   doc_opts.step_per_update: #steps to perform each update (default: 1)
%   doc_opts.step_size: step size (default: 0.1)
%   doc_opts.nFinal: #final global atoms (default: 3)
%   doc_opts.atom_freq: needed to get the final global atoms
%
% para_opts: options for finding representative atoms for the paragraphs
% (include the options in find_rep_atom_for_para)
%
%
% OUTPUT
% doc_atomids: the ids of the representative atoms for the document
% doc_info: additional info for the document
%  doc_info.atom_coeff: the coefficients for the atoms
%  When doc_opts.doc_method =  'share':
%  doc_info.doc_centers: the centers for the documents 
%
% para_rep_atomids: a cell array, para_rep_atomids{i} contains the ids of
% the representative atoms for the i-th paragraph
% para_info: para_info{i} is the additional info for the i-th paragraph
% (see the output info in find_rep_atom_for_para)

% parse options
if ~exist('doc_opts', 'var')
    doc_opts = [];
end

if isfield(doc_opts, 'doc_method')
    doc_method = doc_opts.doc_method;
else
    doc_method = 'separate'; % default
end

if strcmp(doc_method, 'separate')
[doc_rep_atomids, doc_info, para_rep_atomids, para_info] = ...
    find_rep_atom_for_doc_separate(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts);
elseif strcmp(doc_method, 'share')
[doc_rep_atomids, doc_info, para_rep_atomids, para_info] = ...
    find_rep_atom_for_doc_share(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts);
else
    fprintf('Error: unrecognized doc method: %s \n', doc_method);
end
end % function

function [doc_rep_atomids, doc_info, para_rep_atomids, para_info] = find_rep_atom_for_doc_separate(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts)
if ~isfield(doc_opts, 'nRep')
    doc_opts.nRep = 5;
end

if ~isfield(doc_opts, 'n_weight_paras')
    doc_opts.n_weight_paras = 1;
end

if ~isfield(doc_opts, 'para_weight')
    doc_opts.para_weight = 3;
end

% find atoms for paragraphs
nPara = length(doc_para_wordids);
all_atomids = [];
all_wordids = [];
para_rep_atomids = cell(nPara, 1);
para_info = cell(nPara, 1);
for j = 1:nPara
    [para_rep_atomids{j}, para_info{j}] = ...
        find_rep_atom_for_para(doc_para_wordids{j}, Dictionary, WordVector, para_opts);
    fprintf('#atoms for para %d: %d\n', j, length(para_rep_atomids{j}));
    all_atomids = [all_atomids; reshape(para_rep_atomids{j}, [], 1)];
    all_wordids = [all_wordids; reshape(doc_para_wordids{j}, [], 1)];
end

% find atoms for the document
[doc_rep_atomids, ~] = find_rep_atom(all_atomids, Dictionary, doc_opts);
all_wordids = all_wordids(all_wordids > 0);
inner = Dictionary(:, doc_rep_atomids)' * WordVector(:, all_wordids);
[~, mid] = max(inner); 
doc_info.atom_coeff = zeros(length(doc_rep_atomids), 1);
for j = 1:length(doc_rep_atomids)
    doc_info.atom_coeff(j) = sum(mid == j);
end

end % function


function [doc_rep_atomids, doc_info, para_rep_atomids, para_info] = ...
    find_rep_atom_for_doc_share(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts)
% doc_opts: options for the document
%   doc_opts.nRep: #global atoms (default: 5)
%   doc_opts.update_iter: #iterations 
%   doc_opts.reg_weight: the regularization weight on associated_centers
%   (default: 1.0)
%
%   doc_opts.step_per_update: #steps to perform each update (default: 1)
%   doc_opts.step_size: step size (default: 0.1)
%   doc_opts.nFinal: #final global atoms (default: 3)
%   doc_opts.atom_freq: needed to get the final global atoms

if ~isfield(doc_opts, 'nRep')
    doc_opts.nRep = 5;
end

if isfield(doc_opts, 'update_iter')
    update_iter = doc_opts.update_iter;
else
    update_iter = 10; 
end

if ~isfield(doc_opts, 'reg_weight')
    doc_opts.reg_weight = 1.0;
end

if ~isfield(doc_opts, 'nFinal')
    doc_opts.nFinal = 3;
end

% init
[doc_centers, doc_info, para_centers, para_info, para_rep_atomids, info] = ...
    init_local_global(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts);

% update
for i = 1:update_iter
    [doc_centers, doc_info, para_centers, para_info] = ...
        update_local_global(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts,...
        doc_centers, doc_info, para_centers, para_info, info);
end

% finalize
[doc_rep_atomids, doc_info] = ...
    finalize_local_global(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts, ...
    doc_centers, doc_info);

end % function

function [doc_centers, doc_info, para_centers, para_info, para_rep_atomids, info] = ...
    init_local_global(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts)
% info: additional informatioin
% info.para2doc: a cell array, info.para2doc{i}(j) = k means that the j-th
% atom for i-th para is associated with the k-th global atom in
% doc_rep_atomids, and k=-1 means no associated global atoms 

% initialize using separate method
[doc_rep_atomids, doc_info, para_rep_atomids, para_info] = ...
    find_rep_atom_for_doc_separate(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts);
doc_info.doc_rep_atomids = doc_rep_atomids; % bookkeeping
doc_centers = Dictionary(:, doc_rep_atomids); % get centers
para_centers = cell(size(para_info));
for i = 1:length(para_info)
    para_info{i}.para_rep_atomids = para_rep_atomids{i}; % bookkeeping
    para_centers{i} = para_info{i}.cluster_centroids;
end


% initialize the association between global and local atoms
info.para2doc = cell(size(para_rep_atomids));
for i = 1:length(para_rep_atomids)
    info.para2doc{i} = zeros(size(para_rep_atomids{i}));
    % use maximum matching to associate
    inner = Dictionary(:, para_rep_atomids{i})' * Dictionary(:, doc_rep_atomids) + 1;
    [~, mlocal, mglobal] = bipartite_matching(inner);
    info.para2doc{i}(mlocal) = mglobal;
end

end % function

function [doc_centers, doc_info, para_centers, para_info] = ...
        update_local_global(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts,...
        pre_doc_centers, doc_info, pre_para_centers, para_info, info)
% update local
para_centers = cell(size(pre_para_centers));
for i = 1:length(pre_para_centers) % para
    associated_centers = zeros(size(pre_para_centers{i}));
    for j = 1:size(pre_para_centers{i}, 2)
        if info.para2doc{i}(j) > 0
            associated_centers(:, j) = pre_doc_centers(:, info.para2doc{i}(j));
        else
            % will be all zero o.w.
        end
    end
    para_centers{i} = update_local(pre_para_centers{i}, associated_centers, para_info{i}.atom_word_ids, WordVector, doc_opts);
end

% update global
doc_centers = update_global(pre_doc_centers, para_centers, info, doc_opts);

end % function

function doc_centers = update_global(pre_doc_centers, pre_para_centers, info, opts)
% opts: options
%   opts.step_per_update: #steps to perform each update (default: 1)
%   opts.step_size: step size (default: 0.1)

if isfield(opts, 'step_per_update')
    step_per_update = opts.step_per_update;
else
    step_per_update = 1;
end

if isfield(opts, 'step_size')
    step_size = opts.step_size;
else
    step_size = 0.1;
end

for i = 1:step_per_update % each update step
    center_update = zeros(size(pre_doc_centers));
    for j = 1:size(pre_doc_centers, 2) % each doc center
        count = 0;
        for k = 1:length(info.para2doc)
            ass_aids = (info.para2doc{k} == j);
            center_update(:, j) = center_update(:,j) + sum(pre_para_centers{k}(:, ass_aids), 2); 
            count = count + sum(ass_aids);
        end
        if(count > 0)
            center_update(:, j) = center_update(:, j) / count;
        end
    end
    doc_centers = pre_doc_centers * (1 - step_size) + step_size * center_update;
end
end % function

function para_centers = update_local(pre_para_centers, associated_centers, cluster_wordids, WordVector, opts)
% associated_centers: will be all zero if not assciated
% opts: options
%   opts.reg_weight: the regularization weight on associated_centers
%   (default: 1.0)
%   opts.step_per_update: #steps to perform each update (default: 1)
%   opts.step_size: step size (default: 0.1)

% parse options
if isfield(opts, 'reg_weight')
    reg_weight = opts.reg_weight;
else
    reg_weight = 1.0;
end

if isfield(opts, 'step_per_update')
    step_per_update = opts.step_per_update;
else
    step_per_update = 1;
end

if isfield(opts, 'step_size')
    step_size = opts.step_size;
else
    step_size = 0.1;
end

for i = 1:step_per_update
    center_update = zeros(size(pre_para_centers));
    for j = 1:size(pre_para_centers, 2)
        if nnz(associated_centers(:,j)) > 0
            center_update(:, j) = (reg_weight * associated_centers(:,j) + sum(WordVector(:, cluster_wordids{j}), 2)) ...
                / (reg_weight + length(cluster_wordids{j}));
        else
            center_update(:, j) = (reg_weight * associated_centers(:,j) + sum(WordVector(:, cluster_wordids{j}), 2)) ...
                / length(cluster_wordids{j});        
        end
    end
    para_centers = pre_para_centers * (1 - step_size) + step_size * center_update;
end
end % function 

function [doc_rep_atomids, doc_info] = ...
        finalize_local_global(doc_para_wordids, Dictionary, WordVector, para_opts, doc_opts,...
        pre_doc_centers, pre_doc_info)

inner = Dictionary' * pre_doc_centers;
[~, pre_doc_rep_atomids] = max(inner);

% remove too frequent atoms
if isfield(para_opts, 'atom_freq') && isfield(doc_opts, 'nFinal')
    if doc_opts.nFinal >= length(pre_doc_rep_atomids) % do nothing
        doc_rep_atomids = pre_doc_rep_atomids;
        doc_info.doc_centers = pre_doc_centers;
    else        
        [~, sid] = sort(para_opts.atom_freq(pre_doc_rep_atomids), 'ascend');
        sel_id = sid(1:min(doc_opts.nFinal, length(sid)));
        doc_rep_atomids = pre_doc_rep_atomids(sel_id);
        doc_info.doc_centers = pre_doc_centers(sel_id);
    end
end

% compute atom coefficients
all_wordids = [];
for j = 1:length(doc_para_wordids)
    all_wordids = [all_wordids; reshape(doc_para_wordids{j}, [], 1)];
end
all_wordids = all_wordids(all_wordids > 0);
inner = Dictionary(:, doc_rep_atomids)' * WordVector(:, all_wordids);
[~, mid] = max(inner); 
doc_info.atom_coeff = zeros(length(doc_rep_atomids), 1);
for j = 1:length(doc_rep_atomids)
    doc_info.atom_coeff(j) = sum(mid == j);
end

end % function