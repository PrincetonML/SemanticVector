function [cos_sim, info]= atom_word_cos(dict, WordVector, opts)
%Compute the cos sim between the atom and its nearby words 
% dict: each column is an atom
% WordVector: each column is a word vector
% opts: options
%  opts.nNN: #nearby words to use (default 10)
%
% cos_sim: cos_sim(i,j) is the cos sim between the i-th atom and its j-th
% nearest word vector
% info: additional info
%  info.wordids: wordids(i,:) are the the ids of the nearby words of the
%  i-th atom

if exist('opts', 'var') && isfield(opts, 'nNN')
    nNN = opts.nNN;
else
    nNN = 10;
end

cos_sim = zeros(size(dict,2), nNN);
info.wordids = zeros(size(dict,2), nNN);
WordVector = normc(WordVector);
dict = normc(dict);
for i = 1:size(dict,2)
    inner = dict(:,i)'*WordVector;
    [sval, sid] = sort(inner, 'descend');
    cos_sim(i, :) = sval(1:nNN);
    info.wordids(i, :) = sid(1:nNN);
end

end % function