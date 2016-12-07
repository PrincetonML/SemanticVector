function display_win_dict_rep(coeff, corr_words)
%Display the representation coeff

atomids = find(coeff);
coeff = coeff(atomids);
nNN = 10;
for j = 1:length(atomids)
    fprintf('%20f ', coeff(j));
    if j == length(atomids)
        fprintf('\\\\ \n');
    else
        fprintf('& ');
    end
end
for i = 1:nNN
    for j = 1:length(atomids)
        fprintf('%20s ', corr_words{i, atomids(j)});
        if j == length(atomids)
            fprintf('\\\\ \n');
        else
            fprintf('& ');
        end
    end
end

end % function