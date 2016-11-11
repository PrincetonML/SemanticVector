%add paths to utility functions and tools

root_dir = pwd();

vec_util_dir = fullfile(root_dir, 'vector', 'util');
vec_eval_dir = fullfile(root_dir, 'vector', 'eval');
addpath(vec_util_dir);
addpath(vec_eval_dir);
clear vec_util_dir vec_eval_dir

dict_learn_dir = fullfile(root_dir, 'dictionary', 'learn');
addpath(dict_learn_dir);
clear dict_learn_dir 

topic_dir = fullfile(root_dir, 'topic');
topic_math_dir = fullfile(root_dir, 'topic', 'math'); 
topic_display_dir = fullfile(root_dir, 'topic', 'display'); 
addpath(topic_dir);
addpath(topic_math_dir);
addpath(topic_display_dir);
clear topic_dir topic_math_dir topic_display_dir

clear root_dir

cd ./dictionary/tools/smallbox-2.1
SMALLboxInit
cd ../../..
