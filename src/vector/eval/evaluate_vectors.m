function ACC = evaluate_vectors(vectors, questions_array, opts)
% function ACC = evaluate_vectors(vectors, questions_array, opts)
%  evaluate the performance of the vectors on word analogy tasks
% 
% INPUT
%  vectors: word vectors. Each column is a vector
%  questions_array: questions_array(i) is a list of questions in a file; 
%                   contains filename, ind1, ind2, ind3, ind4; filename can
%                   be omitted
%                      
% OPTIONAL INPUT
%  opts: options for the function
%    opts.topn (default 1): evaluation the best topn answers
%    opts.eval_cri (default 1): 
%                   0. use the square norm of (a-b) - (c-d) for a:b::c:d;
%                   1. 3COS-ADD
%                   2. 3COS-MUL
%                   3. skew norm: ((a-b) - (c-d))^t WW^t ((a-b) - (c-d))
%    opts.n_semantic (default 6): number of semantic question files
% 
% OUTPUT
%   ACC: an array containing accuracy for each question file

ACC = zeros(length(questions_array), 1);

if exist('opts','var') && isfield(opts,'topn')
	topn = opts.topn;
else
	topn = 1;
end
if exist('opts','var') && isfield(opts,'n_semantic')
	n_semantic = opts.n_semantic;
else
	n_semantic = 6;
end

if ~(exist('opts','var') && isfield(opts,'eval_cri'))
    opts.eval_cri = 1; % default
end
if opts.eval_cri==0
    fprintf('criteria: |(a-b) - (c-d)|^2\n');
elseif opts.eval_cri==1
    fprintf('criteria: cos(d,b) + cos(d,b) - cos(d,a)\n');
elseif opts.eval_cri==2
    fprintf('criteria: cos(d,b)cos(d,b)/cos(d,a)\n');
elseif opts.eval_cri==3
    fprintf('criteria: |(a-b) - (c-d)|_Cov^2\n');
else
    fprintf('unknown evaluation criteria\n');
    exit(1);
end
if (opts.eval_cri == 1 || opts.eval_cri == 2)
    vectors=normc(vectors); % normalize vectors
    fprintf('normalize vectors\n');
end
if (opts.eval_cri == 3)
    Cov = vectors*vectors';
    normCov = zeros(size(vectors,2),1);
    for cid=1:length(normCov)
        normCov(cid) = vectors(:,cid)' * Cov * vectors(:,cid); 
    end
end
normW = (sum(vectors.*vectors))';

% stat
split_size = 2; %to avoid memory overflow, could be increased/decreased depending on system and vocab size

correct_sem = 0; %count correct semantic questions
correct_syn = 0; %count correct syntactic questions
correct_tot = 0; %count correct questions
count_sem = 0; %count all semantic questions
count_syn = 0; %count all syntactic questions
count_tot = 0; %count all questions
full_count = 0; %count all questions, including those with unknown words

% compute
for j=1:length(questions_array)
% prune questions that contain words not in vocab
ind1 = questions_array(j).ind1;
ind2 = questions_array(j).ind2;
ind3 = questions_array(j).ind3;
ind4 = questions_array(j).ind4;

full_count = full_count + length(ind1);
ind = (ind1 > 0) & (ind2  > 0) & (ind3  > 0) & (ind4 > 0); %only look at those questions which have no unknown words
ind1 = ind1(ind);
ind2 = ind2(ind);
ind3 = ind3(ind);
ind4 = ind4(ind);
count_tot = count_tot + length(ind1);

if isfield(questions_array(j),'filename')
    disp([questions_array(j).filename ':']);
else
    disp(['questions' num2str(j) ' :']);
end

mxtopn = zeros(topn, length(ind1));
num_iter = ceil(length(ind1)/split_size);
for jj=1:num_iter
    bid = (jj-1)*split_size+1;
    eid = min(jj*split_size,length(ind1));
    range = bid:eid;
    if (opts.eval_cri==0) % square norm of (a-b)-(c-d)
        similarity = full(vectors' * (vectors(:,ind2(range)) - vectors(:,ind1(range)) +  vectors(:,ind3(range)))) - normW*ones(1,length(range))*0.5;
    elseif (opts.eval_cri==1) % 3COS-ADD
        %cosine similarity if input W has been normalized        
        similarity = full(vectors' * (vectors(:,ind2(range)) - vectors(:,ind1(range)) +  vectors(:,ind3(range)) ));
    elseif (opts.eval_cri==2) % 3COS-MUL
        tmp1=(vectors' * vectors(:,ind1(range))); tmp1 = (tmp1+1)/2;
        tmp2=(vectors' * vectors(:,ind2(range))); tmp2 = (tmp2+1)/2;
        tmp3=(vectors' * vectors(:,ind3(range))); tmp3 = (tmp3+1)/2;
        tmp1 = tmp1 + 0.001;
        similarity = tmp2.*tmp3 ./ tmp1;
    elseif (opts.eval_cri==3) % skew norm
        similarity = full(vectors' * Cov * (vectors(:,ind2(range)) - vectors(:,ind1(range)) +  vectors(:,ind3(range)))) - normCov*ones(1,length(range))*0.5;
    end
    for i=1:length(range)
        similarity(ind1(range(i)),i) = -Inf;
        similarity(ind2(range(i)),i) = -Inf;
        similarity(ind3(range(i)),i) = -Inf;
    end
    
    [~,mxtopn(:,range)]=get_topn(similarity, topn);
end % for jj=1:num_iter

val=get_accu(mxtopn, ind4, topn);

correct_tot = correct_tot + sum(val);
disp(['ACCURACY TOP' num2str(topn) ': ' num2str(mean(val)*100,'%-2.2f') '%  (' num2str(sum(val)) '/' num2str(length(val)) ')']);
if j < n_semantic
    count_sem = count_sem + length(ind1);
    correct_sem = correct_sem + sum(val);
else
    count_syn = count_syn + length(ind1);
    correct_syn = correct_syn + sum(val);
end

ACC(j) =  sum(val)/length(ind1);

disp(['Total accuracy: ' num2str(100*correct_tot/count_tot,'%-2.2f') ...
    '%   Semantic accuracy: ' num2str(100*correct_sem/count_sem,'%-2.2f') ...
    '%    Syntactic accuracy: ' num2str(100*correct_syn/count_syn,'%-2.2f') '%']);

end % questions_array

disp('________________________________________________________________________________');
disp(['Questions seen/total: ' num2str(100*count_tot/full_count,'%-2.2f') '%  (' num2str(count_tot) '/' num2str(full_count) ')']);
disp(['Semantic Accuracy: ' num2str(100*correct_sem/count_sem,'%-2.2f') '%   (' num2str(correct_sem) '/' num2str(count_sem) ')']);
disp(['Syntactic Accuracy: ' num2str(100*correct_syn/count_syn,'%-2.2f') '%   (' num2str(correct_syn) '/' num2str(count_syn) ')']);
disp(['Total Accuracy: ' num2str(100*correct_tot/count_tot,'%-2.2f') '%   (' num2str(correct_tot) '/' num2str(count_tot) ')']);

