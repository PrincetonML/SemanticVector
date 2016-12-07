function display_atom(atom_ids, atom_coeffs, corr_words)
    for k = 1:length(atom_ids)
        fprintf('\t\tDiscourse %d (coeff %f) ', atom_ids(k), atom_coeffs(k));
        display_corr_words(atom_ids(k), corr_words, 10);
    end
end