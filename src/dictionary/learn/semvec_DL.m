function DL=semvec_DL(X, nAtoms, nSparsity, nStep, initDict)
% each column of X is a data point

if nargin<2
nAtoms  = 500;						%number of atoms in the dictionary
end
if nargin<3
nSparsity = 5;						%sparsity level
end
if nargin<4
nStep = 100;	                        %number of steps in each dictionary learning iterations
end
if nargin<5
initDict = normc(randn(size(X,1),nAtoms));	%random initial dictionary
end

% apply dictionary learning algorithm
ksvd_params = struct('data',X,...			%training data
					 'Tdata',nSparsity,...	%sparsity level
					 'dictsize',nAtoms,...	%number of atoms
					 'initdict',initDict,...%initial dictionary
					 'iternum',nStep);		%number of iterations
DL = SMALL_init_DL('ksvd','ksvd',ksvd_params); %dictionary learning structure
DL.D = initDict;							%copy initial dictionary in solution variable
problem = struct('b',X);					%copy training data in problem structure

DL.ksvd_params.initdict = DL.D;
DL = SMALL_learn(problem,DL);			%learn dictionary

end

