function coeff = win_dict_rep(wordids, WordVector, win_dict, opts)
%Compute the representation for a window/paragraph of words
% wordids: an array, the ids of the words in the window
% WordVector: word vectors  
% win_dict: each column is an atom
% opts: options
%   opts.word_weights: word_weights(i) is the weight for the word with id i
%   (default: all 1)
%   opts.pc: a vector (default not set). If set, remove the projection of the window vector
%   on this vector before computing the representation
%   opts.nSparsity: sparsity in the representation (default 5)
%
%   opts.win_size: truncated the string into windows of size win_size,
%   compute the representation for each window, and then average them. (default: not set)
%   opts.merge_win: 'original' 'sum' 'average'
%    the method to merge the vectors for different windows. 'original':
%    return the vectors for all windows; 'sum': sum the vectors; 'average':
%    return the average. (default: 'average')

if ~exist('opts', 'var')
    opts = [];
end

if isfield(opts, 'win_size') 
    coeff = win_dict_rep_size(wordids, WordVector, win_dict, opts); % redirect 
    return;
end

if isfield(opts, 'nSparsity')
    nSparsity = opts.nSparsity;
else
    nSparsity = 5;
end

test_para_vec = get_win_vector(wordids, WordVector, opts);
if isfield(opts, 'pc')
    test_para_vec = test_para_vec - opts.pc * (opts.pc)' * test_para_vec;
end
if nSparsity > size(win_dict, 2)
    nSparsity = size(win_dict, 2); % sparsity should be smaller than #atoms
end
coeff = get_sparse_rep(win_dict, test_para_vec, nSparsity);

end % function


function coeff = win_dict_rep_size(wordids, WordVector, win_dict, opts)
%Compute the representation for a window/paragraph of words
% wordids: an array, the ids of the words in the window
% WordVector: word vectors  
% win_dict: each column is an atom
% opts: options
%   opts.word_weights: word_weights(i) is the weight for the word with id i
%   (default: all 1)
%   opts.pc: a vector (default not set). If set, remove the projection of the window vector
%   on this vector before computing the representation
%   opts.nSparsity: sparsity in the representation (default 5)
%
%   opts.win_size: truncated the string into windows of size win_size,
%   compute the representation for each window, and then average them. 
%   (default: not set. If not set or <= 0, use the whole string as window)
%   opts.merge_win: 'original' 'sum' 'average'
%    the method to merge the vectors for different windows. 'original':
%    return the vectors for all windows; 'sum': sum the vectors; 'average':
%    return the average. (default: 'average')

if ~exist('opts', 'var')
    opts = [];
end

if isfield(opts, 'nSparsity')
    nSparsity = opts.nSparsity;
else
    nSparsity = 5;
end

if isfield(opts, 'win_size') && opts.win_size > 0
    win_size = opts.win_size;
else
    win_size = length(wordids);
end

if isfield(opts, 'merge_win') 
    merge_win = opts.merge_win;
else
    merge_win = 'average';
end

if nSparsity > size(win_dict, 2)
    fprintf('Warning: sparsity changed from %d to %d\n', nSparsity, size(win_dict, 2));
    nSparsity = size(win_dict, 2); % sparsity should be no larger than #atoms
end

nWin = ceil(length(wordids) / win_size);
coeff = zeros(size(win_dict, 2), nWin);
for i = 1:nWin
    bid = 1 + (i-1) * win_size;
    eid = min(i * win_size, length(wordids));

    test_para_vec = get_win_vector(wordids(bid:eid), WordVector, opts);
    if isfield(opts, 'pc')
        test_para_vec = test_para_vec - opts.pc * (opts.pc)' * test_para_vec;
    end
    coeff(:, i) = get_sparse_rep(win_dict, test_para_vec, nSparsity);
end

if strcmp(merge_win, 'average')
    coeff = mean(coeff, 2);
elseif strcmp(merge_win, 'sum')
    coeff = sum(coeff, 2);
elseif strcmp(merge_win, 'original')
    % return the original coeff
    return;
else
    fprintf('Error: do not recognize merge window method %s\n', merge_win);
end
    
end % function