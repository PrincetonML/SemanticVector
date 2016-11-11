% function vectors = read_bin(bin_file, column_dim, read_column_num)
%  read read_column_num vectors from a bin file containing binary
%  vectors. The bin file should store the vectors in binary, and in double
%  precision.
%
% INPUT
%  bin_file: the name of the vector file.
% OPTIONAL INPUT
%  column_dim (default 300): the dimension of the vectors
%  read_column_num (default Inf): the number of vectors to be read. Default to be the 
%      number of all vectors
%
% OUTPUT
%  vectors: the vectors. Each column is a vector.

function vectors = read_bin(bin_file,column_dim, read_column_num)
    if nargin < 2
		column_dim = 300;
    end
    if nargin < 3
        read_column_num = Inf;
    end
	    
    fid = fopen(bin_file,'r');
    fseek(fid,0,'eof');
    frewind(fid);
    vectors = fread(fid, [column_dim read_column_num], 'double')'; 
    fclose(fid); 
end