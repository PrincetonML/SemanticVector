% function [scoretop,mxtopn]=get_topn(score, topn)
%  get the top ones based on the score
%
% INPUT:
%  score: a matrix, where entry (i,j) is the score of the i-th word for the
%    j-th question
%  topn: a number 
%
% OUTPUT:
%  scoretop: a matrix with the same number of columns as score but only topn
%    rows. Entry (i,j) is the score of the top i word for the question j.
%  mxtopn: a matrix. Entry (i,j) is the index of the top i word for the question j.

function [scoretop,mxtopn]=get_topn(score, topn)
n_ques=size(score,2);
mxtopn = zeros(topn, n_ques);
scoretop = zeros(topn, n_ques);
if topn==1
    [scoretop, mxtopn] = max(score); %predicted word index
else
    for i=1:n_ques
         [~,sortInd]=sort(score(:,i),'descend');
         mxtopn(:,i)=sortInd(1:topn);    
         scoretop(:,i)=score(mxtopn(:,i),i);
    end
end
end