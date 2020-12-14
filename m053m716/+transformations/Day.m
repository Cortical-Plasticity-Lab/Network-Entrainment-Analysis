function [day_sigmoid,day_linear] = Day(day_starting_from_one)
%DAY Returns sigmoid transformation on linear version of post-operative day
%
%  [day_sigmoid,day_linear] = transformation.Day(day_starting_from_one);
%
% Inputs
%  day_starting_from_one - Day with minimum value as 1, on linear scale
%  
% Output
%  day_sigmoid - Sigmoidally-transformed days
%  day_linear  - Linear days scale, with correct postoperative day as
%                 earliest value (post-op day 6)
%
% See also: Contents, importFRstats, importIOstats

day_linear = day_starting_from_one + 5; % First recording on post-op day 6
day_sigmoid = tanh((day_linear - 16)/5); % Applies sigmoidal transform

end