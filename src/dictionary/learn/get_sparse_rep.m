function [solution,sparse_rep_solver]=get_sparse_rep(Dict, Data, nSparsity)
if nargin<3
    nSparsity=5;
end

coefficientProblem.A = Dict;
coefficientProblem.b = Data;
coefficientProblem.signalSize = size(Data,1);

sparse_rep_solver=SMALL_init_solver;
sparse_rep_solver.toolbox='SMALL';    
sparse_rep_solver.name='SMALL_pcgp';
% In the following string all parameters except matrix, measurement vector
% and size of solution need to be specified. If you are not sure which
% parameters are needed for particular solver type "help <Solver name>" in
% MATLAB command line
sparse_rep_solver.param=[num2str(nSparsity) ', 1e-10'];
sparse_rep_solver=SMALL_solve(coefficientProblem,sparse_rep_solver);
solution=sparse_rep_solver.solution;
end