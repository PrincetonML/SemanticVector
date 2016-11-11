function [ dict ] = merge_dictionaries( dictionaries, threshold_merge, threshold_drop, occur )
%this function takes many dictionaires and try to merge them.
% INPUT:
% dictionaries: an array. dictionaries(i).dict is the i-th dictionary
% threshold_merge:if the inner product between two atoms is above this then 
%      count them as one atom
% threshold_drop: if the inner product between two atoms is above this then
%      count them as neighbors
% occur: keep an atom if it has more than this number of neighbors
% OUTPUT:
% dict: the merged dictionary

    for i = 1:length(dictionaries)
        dictionaries(i).dict = full(dictionaries(i).dict);
    end
    
    %first gether atoms from all dictionaries. 
    dict = [];
    for i = 1:length(dictionaries)
        dict1 = dictionaries(i).dict;
        degree1 = zeros(1, length(dict1(1, :)));
        for j = i:length(dictionaries)
            dict2 = dictionaries(j).dict;
            G = dict1'*dict2;
            
            for k = 1:length(G(:, 1))
                entry = G(k, :);
                degree1(k) = degree1(k) + sum(abs(entry) > threshold_drop);
            end
        end
        %add atom
        dict = [dict, dict1(:, degree1 >= occur)];
    end
    
    disp(['merging... number of atoms: ', num2str(length(dict(1, :)))]);
    
    %merge
    ind_remove = [];
    for i = 1:length(dict(1, :))
        atom1 = dict(:, i);
        for j = (i + 1):length(dict(1, :))
            atom2 = dict(:, j);
            if atom1'*atom2 > threshold_merge
                ind_remove = [ind_remove, j];
            end
        end
        
    end
    ind_survive = setdiff(1:length(dict(1, :)), ind_remove);
    dict = dict(:, ind_survive);
    
end

