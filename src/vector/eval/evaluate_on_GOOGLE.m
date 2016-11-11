function evaluate_on_GOOGLE(vocab, vectors, testbed_dir)
%evaluate the word vectors on GOOGLE testbed

path = testbed_dir;
filenames = ...%
{
    'capital-common-countries' 
    'capital-world' 
    'currency' 
    'city-in-state' 
    'family' 
    'gram1-adjective-to-adverb'
    'gram2-opposite' 
    'gram3-comparative' 
    'gram4-superlative' 
    'gram5-present-participle' 
    'gram6-nationality-adjective' 
    'gram7-past-tense' 
    'gram8-plural' 
    'gram9-plural-verbs'
};

% read questions
for i = 1:length(filenames)
    [~,questions_array(i).filename,~] = fileparts(filenames{i});
    [questions_array(i).ind1,questions_array(i).ind2,...
        questions_array(i).ind3,questions_array(i).ind4] = ...
        get_questions(vocab,fullfile(path, [filenames{i} '.txt']));
end

% evaluate
evaluate_vectors(vectors, questions_array);