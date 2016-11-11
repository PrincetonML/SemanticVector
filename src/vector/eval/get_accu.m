% function val=get_accu(mxtopn, truth, topn)
%  get the correctness of the mxtopn 
%
% INPUT
%  mxtopn: a matrix. Entry (i,j) is the index of the top i word for question j.
%  truth: an array. Entry i is the index of the groundtruth word for question j.
%  topn: a number.
%
% OUTPUT
%  val: an logical array. Entry i means weather the topn entries in mxtopn
%    contains the grouthtruth.

function val=get_accu(mxtopn, truth, topn)

    if topn==1
        val = (truth == mxtopn(1,:)'); %correct predictions
    else
        val=zeros(size(mxtopn,2),1);
        for i=1:size(mxtopn,2)
            val(i) = ismember(truth(i), mxtopn(1:topn,i));
        end
    end
end