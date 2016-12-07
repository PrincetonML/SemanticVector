function [contrast_atomids, atom_freq] = get_contrast_atomids(para_wordids, Dictionary, WordVector, opts)
% Compute common atoms
% INPUT
% para_wordids: a cell array, para_wordids{i} is the word ids for a
% paragraph
% opts: opts for finding the atoms. optional (default: [])
%    opts.verbose: 0 (no output), 1 (output), 2 (debug)
%    opts.max_para: maximum number of paragraphs to check (default: 1000)
% OUTPUT
% contrast_atomids: id of atoms found in some random pragraphs (a multi-set)
% atom_freq: atom_freq(i) is the occurrence count of the i-th atom

if ~exist('findatom_opts', 'var')
    opts = [];
end

if isfield(opts, 'verbose')
    verbose = opts.verbose;
else
    verbose =  1; % default
end

if isfield(opts, 'max_para')
    max_para = opts.max_para;
else
    max_para =  1000; % default
end

max_rand_para_find = min(max_para, length(para_wordids));
random_paraids = para_wordids(randsample(length(para_wordids), max_rand_para_find));
contrast_atomids = [];
for i = 1:length(random_paraids)
    if(verbose > 0) 
        fprintf('In get_contrast_atomids, computing the atoms for paragraph %d\n', i);
    end
fprintf('opts in  get_contrast_atomids: \n');
display(opts)
    para_atomids = find_atom_for_para(random_paraids{i}, ...
        Dictionary, WordVector, opts);
    contrast_atomids = vertcat(contrast_atomids, para_atomids);
end

atom_freq = zeros(size(Dictionary, 2), 1);
uids = unique(contrast_atomids);
atom_freq(uids) = histc(contrast_atomids, uids);

end % function
