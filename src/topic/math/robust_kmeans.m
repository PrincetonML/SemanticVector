function [cidx, IDX, kC] = robust_kmeans(P, C, k, opts)
% P: each column is a data point
% C: candidate centers; each column is a candidate center
% k: number of centers to select 
%    (if number of data points < k, then the number of centers is 
%     the number of data points)
% opts: options
%   opts.keep_ratio: the percentage of points to keep in each cluster (if
%   in [0,1], keep keep_ratio fraction of the points; if > 1, keep
%   keep_ratio number of points; if not set, use the prune heuristic)
%   (default: not set)
%   opts.weight: a vector containing the weights for the points
% cidx: the index of the centers selected 
% IDX: cluster index of of each point in P, IDX(i)=j means point i is 
% assigned to center with index cidx(j); -1 means outlier
% kC: the true centers in kmeans

if ~exist('opts', 'var')
    opts = [];
end

if isfield(opts, 'weight')
    weight = opts.weight; % will use fkmeans code which allows weights
else
    weight = []; % means uniform, will then use Matlab kmeans code
end

if isfield(opts, 'MaxIter')
    MaxIter = opts.MaxIter;
else
    MaxIter = 50;
end

if isfield(opts, 'keep_ratio')
    keep_ratio = opts.keep_ratio;
else
    keep_ratio = [];
end
fprintf('Use keep_ratio: %f\n', keep_ratio);

% prune far away points
if size(P,2) > k
    [mind, ~, D] = weighted_kmeans(P', k, weight, MaxIter);
    [dist, ~] = min(D, [], 2); 

    keep_ratio1 = []; % default
    if isempty(keep_ratio1)
        [~, sid] = sort(dist, 'descend');
        if length(sid) > 10*k % prune heuristic
            rm_percent = 50;
        else
            rm_percent = 20;
        end
        ssid = sid(floor(rm_percent/100.0*length(sid)):end);
    elseif keep_ratio1 > 0 
        pruned_idx = prune_clusters(dist, mind, keep_ratio1);
        ssid = find(pruned_idx > 0);        
    else
        fprintf('Invalid keep_ratio1 value: %f \n', keep_ratio1);
    end % keep ratio
else
    ssid = 1:size(P, 2);
end

% redo on the remaining points
rP = P(:, ssid);
if isempty(weight)
	rweight = [];
else
	rweight = weight(ssid);
end

fprintf('kmeans #points left: %d\n', size(rP,2));
if size(rP,2) > k
    [rIDX, kC, D] = weighted_kmeans(rP', k, rweight, MaxIter);
    
    % remove points and recompute
    [dist, ~] = min(D, [], 2);  
    pruned_idx = prune_clusters(dist, rIDX, keep_ratio);
    for i = 1:max(rIDX) % update the center after pruning
        kC(i, :) = mean(rP(:, pruned_idx == i)');
    end
    
    [~, cidx] = max(kC * C, [], 2);
    IDX = -1 * ones(size(P,2), 1);
    IDX(ssid) = pruned_idx;
        
    kC = kC'; % each column is a center
else
    kC = rP;
    [~, cidx] = max(rP' * C, [], 2);
    IDX = -1 * ones(size(P,2), 1);
    IDX(ssid) = 1:size(rP, 2);
end

end % function

function [IDX, C, D] = weighted_kmeans(P, k, w, MaxIter)
% each row of P is a data point
if isempty(w)
    [IDX, C, ~, D] = kmeans(P, k, 'MaxIter', MaxIter); 
else
    opts.weight = w;
    opts.careful = true;
    opts.max_iter = MaxIter;
    [IDX, C] = fkmeans(P, k, opts);
    % D = pdist2(P, C, 'squaredeuclidean'); % doesn't work in old Matlab
    D = pdist2(P, C).^2;
end
end % function

function pruned_idx = prune_clusters(dist, ori_idx, keep_ratio)
    if isempty(keep_ratio) % do nothing
        pruned_idx = ori_idx; 
        return;
    end
    
    pruned_idx = -1 * ones(length(ori_idx), 1);      
    for i = 1:max(ori_idx)
        map = find(ori_idx == i);
        if keep_ratio <= 1
            nKeep = ceil(keep_ratio*length(map));
        else
            nKeep = ceil(keep_ratio);
        end 
        fprintf('keep #points: %d\n', nKeep);
        [~, sid] = sort(dist(map), 'ascend');
        keepid = map(sid( 1:min(length(sid), nKeep) ));
        pruned_idx(keepid) = ori_idx(keepid);
    end  
end % function
