function display_win_dict_atom(atomids, corr_words)
%Output nearby words for atoms from the window/paragraph dictionary for eyeballing

nNN = 10;
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

end %function