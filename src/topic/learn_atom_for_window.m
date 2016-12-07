function [Dictionary, representation, info] = learn_atom_for_window(window_wordids, WordVector, words, opts)
%For each window, compute the vector for the window; then learn a
%dictionary over the window vectors
% INPUT
% window_wordids: a cell array, window_wordids{i} is an array containing
% the word ids in the window
% words: the vocabulary
% WordVector: the i-th column is a vector for the i-th word
% opts: options
%  opts.word_weights: an array, word_weights(i) is the weight for the word with id i;
%  used in computing the vectors for the windows (if not set, use all one);
%  Note that after weight, the window vector is divided by the length of
%  the window
%  opts.rm_pc: if set >0, compute the principle component of the window vectors and
%  remove their projections on that component (default: not set)
%  opts.pc: if rm_pc > 0, use opts.pc as the principle component (do not recompute)
%  opts includes the opts in the function learn_dict
%    opts.nAtoms: number of atoms to learned (default 2000)
%    opts.nSparsity: number of atoms to represent each window (default 5)
%  
%   opts.win_size: truncated the string into windows of size win_size,
%   compute the representation for each window, and then average them. 
%   (default: not set. If not set or <= 0, use the whole string as window)
%   opts.merge_win: 'original' 'sum' 'average'
%    the method to merge the vectors for different windows. 'original':
%    return the vectors for all windows (the result for window_wordids{i} is a cell); 
%    'sum': sum the vectors; 'average':
%    return the average. (default: 'average')
%
% OUTPUT
%  Dictionary: each column is an atom
%  representation: the i-th column is the representation coefficients for
%  the i-th window
%  info: additional information
%    info.corr: correlation
%    info.corr_words: correlated words
%    info.pc: the direction, the projections on which of the window vectors
%    are removed (if opts.pc set, then info.pc = opts.pc)

% parse options
if ~exist('opts', 'var')
    opts = [];
end

if isfield(opts, 'win_size') % redirect
    [Dictionary, representation, info] = learn_atom_for_window_size(window_wordids, WordVector, words, opts);
    return;
end

dict_opts = opts;
if isfield(opts, 'nAtoms')
    dict_opts.nAtoms = opts.nAtoms;
else
    dict_opts.nAtoms = 2000; % default
end

if isfield(opts, 'nSparsity')
    dict_opts.nSparsity = opts.nSparsity;
else
    dict_opts.nSparsity = 5; % default
end

if isfield(opts, 'rm_pc')
    rm_pc = opts.rm_pc;
else
    rm_pc = 0; % default
end

% compute window vectors
nWin = length(window_wordids);
win_vector = zeros(size(WordVector, 1), nWin);
for i = 1:nWin
    win_vector(:, i) = get_win_vector(window_wordids{i}, WordVector, opts);
end

if rm_pc > 0
    if isfield(opts, 'pc')
        info.pc = opts.pc;
    else         
        [info.pc, ~, ~] = svds(win_vector, 1);
    end
    win_vector = win_vector - (info.pc) * (info.pc)' * win_vector;
end

% learn dictionary
if nWin < dict_opts.nAtoms
    dict_opts.nAtoms = floor(nWin/2); % when too few data points 
end
fprintf('nWin %d, nAtoms %d\n', nWin, dict_opts.nAtoms);
[Dictionary, representation] = learn_dict(1:nWin, win_vector, dict_opts);

nNN = 100;
info.corr=zeros(nNN,size(Dictionary,2));
info.corr_words = cell(nNN,size(Dictionary,2));
inn = (normc(WordVector))'*Dictionary;
for i = 1:size(Dictionary,2)  
    [sval,sid]=sort(inn(:, i),'descend'); 
    info.corr(:,i) = sval(1:nNN); 
    info.corr_words(:,i)=words(sid(1:nNN)); 
end
end % function

function [Dictionary, representation, info] = learn_atom_for_window_size(window_wordids, WordVector, words, opts)
%For each window, compute the vector for the window; then learn a
%dictionary over the window vectors
% INPUT
% window_wordids: a cell array, window_wordids{i} is an array containing
% the word ids in the window
% words: the vocabulary
% WordVector: the i-th column is a vector for the i-th word
% opts: options
%  opts.word_weights: an array, word_weights(i) is the weight for the word with id i;
%  used in computing the vectors for the windows (if not set, use all one);
%  Note that after weight, the window vector is divided by the length of
%  the window
%  opts.rm_pc: if set >0, compute the principle component of the window vectors and
%  remove their projections on that component (default: not set)
%  opts.pc: if rm_pc > 0, use opts.pc as the principle component (do not recompute)
%  opts includes the opts in the function learn_dict
%    opts.nAtoms: number of atoms to learned (default 2000)
%    opts.nSparsity: number of atoms to represent each window (default 5)
%  
%   opts.win_size: truncated the string into windows of size win_size,
%   compute the representation for each window, and then average them. 
%   (default: not set. If not set or <= 0, use the whole string as window)
%   opts.merge_win: 'original' 'sum' 'average'
%    the method to merge the vectors for different windows. 'original':
%    return the vectors for all windows (the result for window_wordids{i} is a cell); 
%    'sum': sum the vectors; 'average':
%    return the average. (default: 'average')
%
% OUTPUT
%  Dictionary: each column is an atom
%  representation: the i-th column is the representation coefficients for
%  the i-th window
%  info: additional information
%    info.corr: correlation
%    info.corr_words: correlated words
%    info.pc: the direction, the projections on which of the window vectors
%    are removed (if opts.pc set, then info.pc = opts.pc)

% parse options
if ~exist('opts', 'var')
    opts = [];
end

dict_opts = opts;
if isfield(opts, 'nAtoms')
    dict_opts.nAtoms = opts.nAtoms;
else
    dict_opts.nAtoms = 2000; % default
end

if isfield(opts, 'nSparsity')
    dict_opts.nSparsity = opts.nSparsity;
else
    dict_opts.nSparsity = 5; % default
end

if isfield(opts, 'rm_pc')
    rm_pc = opts.rm_pc;
else
    rm_pc = 0; % default
end

if isfield(opts, 'win_size') && opts.win_size > 0
    win_size = opts.win_size;
else
    win_size = -1;
end

if isfield(opts, 'merge_win')
    merge_win = opts.merge_win;
else
    merge_win = 'average';
end

% compute window vectors
if win_size > 0
    % compute #windows
    nWin = 0;
    for i = 1:length(window_wordids) 
        nWin = nWin + ceil( length(window_wordids{i}) / win_size); 
    end    
    win_vector = zeros(size(WordVector, 1), nWin);
    win_count = 0;
    for i = 1:length(window_wordids) 
        tnWin = ceil( length(window_wordids{i}) / win_size); 
        for j = 1:tnWin
            bid = 1 + (j-1) * win_size;
            eid = min(j * win_size, length(window_wordids{i}) );
            win_count = win_count + 1;
            win_vector(:, win_count) = get_win_vector(window_wordids{i}(bid:eid), WordVector, opts);
        end
    end
else
    nWin = length(window_wordids);
    win_vector = zeros(size(WordVector, 1), nWin);
    for i = 1:nWin
        win_vector(:, i) = get_win_vector(window_wordids{i}, WordVector, opts);
    end
end

if rm_pc > 0
    if isfield(opts, 'pc')
        info.pc = opts.pc;
    else         
        [info.pc, ~, ~] = svds(win_vector, 1);
    end
    win_vector = win_vector - (info.pc) * (info.pc)' * win_vector;
end

% learn dictionary
if nWin < dict_opts.nAtoms
    fprintf('Warning: number of atoms changed from %d to %d\n', dict_opts.nAtoms, floor(nWin/2));
    dict_opts.nAtoms = floor(nWin/2); % when too few data points 
end
fprintf('nWin %d, nAtoms %d\n', nWin, dict_opts.nAtoms);
[Dictionary, temp_representation] = learn_dict(1:nWin, win_vector, dict_opts);

if win_size < 0
    representation = temp_representation;
elseif strcmp(merge_win, 'average')
    representation = zeros(size(temp_representation, 1), length(window_wordids));
    win_count = 0;
    for i = 1:length(window_wordids) 
        tnWin = ceil( length(window_wordids{i}) / win_size); 
        representation(:, i) = mean( temp_representation((win_count+1):(win_count+tnWin)), 2);
        win_count = win_count+tnWin;
    end
elseif strcmp(merge_win, 'sum')
    representation = zeros(size(temp_representation, 1), length(window_wordids));
    win_count = 0;
    for i = 1:length(window_wordids) 
        tnWin = ceil( length(window_wordids{i}) / win_size); 
        representation(:, i) = sum( temp_representation((win_count+1):(win_count+tnWin)), 2);
        win_count = win_count+tnWin;
    end
elseif strcmp(merge_win, 'original')
    % return the original representation but reorganized
    representation = cell(length(window_wordids), 1);
    win_count = 0;
    for i = 1:length(window_wordids) 
        tnWin = ceil( length(window_wordids{i}) / win_size); 
        representation{i} = temp_representation((win_count+1):(win_count+tnWin));
        win_count = win_count+tnWin;
    end
else
    fprintf('Error: do not recognize merge window method %s\n', merge_win);
end

nNN = 100;
info.corr=zeros(nNN,size(Dictionary,2));
info.corr_words = cell(nNN,size(Dictionary,2));
inn = (normc(WordVector))'*Dictionary;
for i = 1:size(Dictionary,2)  
    [sval,sid]=sort(inn(:, i),'descend'); 
    info.corr(:,i) = sval(1:nNN); 
    info.corr_words(:,i)=words(sid(1:nNN)); 
end
end % function
 
 