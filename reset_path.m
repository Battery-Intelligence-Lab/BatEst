function reset_path()
% This script adds Code, Code\Common and its subfolders, and Data\Examples
% to the MATLAB path. Once the model has been selected in main.m, the
% relevant files for the chosen model and method are added.

codepath = genpath('.\Code\');
addpath(codepath);
rmpath(codepath);

addpath('.\Code\');
addpath(genpath('.\Code\Common\'));

addpath('.\Data\Examples\');

end
