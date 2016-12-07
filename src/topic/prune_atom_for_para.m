function pruned_para_atomids = prune_atom_for_para(para_wordids, para_atomids, para_atomid4word, opts)
% Prune the atoms for a paragraph
% INPUT
% para_wordids: the array of word ids in a paragraph; can have word id -1 for out-of-vocabulary words
% para_atomids: atomids before pruning
% para_atomid4word: para_atomid4word(i) = j means the i-th word is assigned
% to atom j
% opts: options
%  opts.target_wordid: if set >0, return only the atoms active for this word
%  (default: not set)
%
%  opts.around_wordid: if set >0, return only the atoms active around this
%  word (default: not set)
%  opts.around_wordid_win: when set opts.around_wordid, use this as the
%  window size around the word (default 10)
%
%  opts.atom_freq: an array containing the frequency of the atoms (can be unnormalized)
%  opts.select_nAtom: if opts.atom_freq is set, keep only
%    opts.select_nAtom atoms after filtering (default: 3). 
%    That is, remove too frequent atoms according to opts.atom_freq
%    (do after opts.around_wordid and opts.target_wordid)
%  opts.min_unique_words: remove atoms that are used by too few words
%  (default: 2)
% 
% OUTPUT
% pruned_para_atomids: a row array of atom ids for the paragraph (can be empty)

% parse options
if ~exist('opts', 'var')
    opts = [];
end

if isfield(opts, 'around_wordid_win')
    around_wordid_win = opts.around_wordid_win;
else
    around_wordid_win = 10; % default
end

if isfield(opts, 'select_nAtom')
    select_nAtom = opts.select_nAtom;
else
    select_nAtom = 3; % default
end

if isfield(opts, 'min_unique_words')
    min_unique_words = opts.min_unique_words;
else
    min_unique_words = 2; % default
end

% target word id
if isfield(opts, 'target_wordid') && (opts.target_wordid > 0)
    temp = unique(para_atomid4word(para_wordids == opts.target_wordid));
    temp = temp(temp>0);
    pruned_para_atomids = temp;
end

% around word id
if isfield(opts, 'around_wordid') && (opts.around_wordid > 0)
    wid_pos = find(para_wordids == opts.around_wordid);
    around_centerids = [];
    for posid = 1:length(wid_pos)
        bid = max(1, wid_pos(posid) - around_wordid_win);
        eid = min(wid_pos(posid) + around_wordid_win, length(para_atomid4word));
        around_centerids = [around_centerids; para_atomid4word(bid:eid)];
    end
    temp = unique(around_centerids);
    temp = temp(temp>0);
    pruned_para_atomids = temp;
end

% remove too frequent atoms
if isfield(opts, 'atom_freq')
    [~, sid] = sort(opts.atom_freq(para_atomids), 'ascend');
    sel_id = sid(1:min(select_nAtom, length(sid)));
    pruned_para_atomids = para_atomids(sel_id);
end

% remove atoms used by too few words
if min_unique_words > 0
    nWords = zeros(size(pruned_para_atomids));
    for i = 1:length(pruned_para_atomids)
        mids = (para_atomid4word == pruned_para_atomids(i));
        nWords(i) = length(unique(para_wordids(mids)));
    end
    pruned_para_atomids = pruned_para_atomids(nWords >= min_unique_words);
end
end % function