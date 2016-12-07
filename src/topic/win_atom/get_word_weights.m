function word_weights = get_word_weights(word_freq, weighting_para)
%compute the word weights from their frequency for estimating the vector
%for a text window
    word_weights = weighting_para ./ (weighting_para + word_freq/sum(word_freq));
end