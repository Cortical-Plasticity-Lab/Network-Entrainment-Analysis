function args = struct2args(s)
%STRUCT2ARGS  Convert struct to <'Name',value> arguments
%
%  args = p__.struct2args(s);
%
%  -- input --
%  s : Any struct
%
%  -- output --
%  args : [2 x k] array of "input argument" pairs for k struct fields,
%           where the top row are the field names and bottom row is their
%           values. This can then be provided as an arbitrary number of
%           <'Name',value> argument pairs to a function that takes varargin
%           as an argument using the syntax `args{:}`

if ~isstruct(s)
   error(['P__:' mfilename ':BadClass'],...
      ['\n\t->\t<strong>[P__.STRUCT2ARGS]</strong> ' ...
       'Input is required to be a struct\n']);
end

f = fieldnames(s);
if iscolumn(f)
   f = f.'; % Transpose it to get correct orientation
end
c = struct2cell(s);
if iscolumn(c)
   c = c.'; % Transpose it to get correct orientation
end

args = vertcat(f,c); 
end