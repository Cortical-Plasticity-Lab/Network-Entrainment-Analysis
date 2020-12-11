function mFileList = findSubdir(aDir, varargin)
%FINDSUBDIR Returns list of files in all sub-dirs
%
% mFileList = p__.findSubdir(aDir)
% mFileList = p__.findSubdir(aDir, 'Name', value, ...)
%
% Inputs
%	aDir - Char vector (name of folder to check)
%   'Name', value pairs:
%		* 'Recurse' : tf (default: false) set true 
%					  to find sub-directories.

% Parse input.
% persistent parser;
% if isempty(parser)
parser = inputParser;
parser.addRequired('Directory', @(d)ischar(d) && isvector(d));
parser.addParamValue('Recurse', false, @(tf)islogical(tf) && isscalar(tf));
% end
parser.parse(aDir, varargin{:});
doRecurse = parser.Results.Recurse;

% Find M-Files.
theDir = parser.Results.Directory;
dirStruct = dir(theDir);
dirIsDir = [dirStruct.isdir];
fileList = dirStruct(~dirIsDir);
mFileList = fileList(~cellfun('isempty', regexp({fileList.name}, '\.m$', 'once')));
mFileList = cellfun(@(f)fullfile(theDir, f), {mFileList.name}, 'UniformOutput', false)';

% If Recurse was specified, find subdirectories.
if doRecurse & any(dirIsDir)
    subdirs = dirStruct(dirIsDir & ...
		cellfun('isempty', regexp({dirStruct.name}, '^\.{1,2}$', 'once')));
    subdirList = {subdirs.name}';
    if ~isempty(subdirList)
        subdirList = strcat(theDir, filesep, subdirList);
        subdirFiles = cellfun(@(d)p__.findSubdir(d, 'Recurse', doRecurse),...
			subdirList, 'UniformOutput', false);
        mFileList = vertcat(mFileList, subdirFiles{:});
    end
end

end
