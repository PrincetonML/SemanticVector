% function [nnzi,nnzj,val]=read_cooc(cooc_file, vocab_size, ind)
%  get the cooc for the words whose indices are in the array ind
% 
% INPUT
%  cooc_file: the name of the coocurrence file
%  vocab_size: the size of the vocabulary
% OPTIONAL INPUT
%  ind: an array containing the indices of the words whose coocurrence data are needed. Default to be 1:vocab_size
% 
% OUTPU
%  nnzi, nnzj, val: non-zero entries in the sparse coocurrence matrix corresponding to the indices.
%    That is, the coocurrence of words indexed by nnzi(k) and nnzj(k) is val(k)

function [nnzi,nnzj,val] = read_cooc(cooc_file, vocab_size, ind)
	if nargin < 3
		ind=1:vocab_size;
	end
	
    recordType = {'int' 'int' 'double'};
    recordLen = [4 4 8];
    split_size=100000000;

    fid=fopen(cooc_file,'rb');
    
    fseek(fid,0,'eof');
    nTRecord = ftell(fid)/sum(recordLen);
    frewind(fid);
    nblock=ceil(double(nTRecord)/split_size);
    
    word1=[]; word2=[]; val=[];
    for blockid=1:nblock
        fprintf('block %d\n', blockid);
        recordBegin=split_size*(blockid-1)+1;
        nRecord=min(split_size*blockid, nTRecord) - recordBegin + 1;
        R=read_bin(fid, recordType, recordLen, recordBegin, nRecord);
        
        kind=(ismember(R{1},ind) & (R{1}<=vocab_size) & (R{2} <= vocab_size));
        word1=vertcat(word1,R{1}(kind));
        word2=vertcat(word2,R{2}(kind));
        val=vertcat(val,R{3}(kind));
    end
    fclose(fid);
	
	nnzi = double(word1);
	nnzj = double(word2);
    
    % tmpw1=zeros(length(word1),1);
    % for i=1:length(ind)
        % tmpw1(word1==ind(i)) = i;
    % end
    % if isempty(word1)
        % cooc_matrix=[];
    % else
        % cooc_matrix=sparse(double(tmpw1), double(word2), val, length(ind),vocab_size);
    % end
end

function R=read_bin(fid, recordType, recordLen, recordBegin, nRecord)
%# type and size in byte of the record fields
R = cell(1,numel(recordType));

%# read column-by-column
for i=1:numel(recordType)
    %# seek to the first field of the first record
    fseek(fid, sum(recordLen)*(recordBegin-1) + sum(recordLen(1:i-1)), 'bof');

    %# % read column with specified format, skipping required number of bytes
    R{i} = fread(fid, nRecord, ['*' recordType{i}], sum(recordLen)-recordLen(i));
end
end
