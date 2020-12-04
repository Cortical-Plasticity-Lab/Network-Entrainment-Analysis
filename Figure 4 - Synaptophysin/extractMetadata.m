function meta = extractMetadata(fdata)
%% EXTRACTMETADATA   Get metadata from file name "header"
%
%  meta = EXTRACTMETADATA(fdata,meta);
%
%  --------
%   INPUTS
%  --------
%   fdata      :     File name that is delimited by '_'. No extension.
%
%   meta       :     Struct with fields to be updated:
%                    'Name','Group','Area','Operator','Section'
%
%  --------
%   OUTPUT
%  --------
%    meta      :     Same as input, but with concatenated metadata
%                       appended.
%
% By: Max Murphy  v1.0  2019-04-18  Original version (R2017a)

%%
fdata = strsplit(fdata,'_');
meta = struct('Name',fdata(1),...
              'Group',fdata(6),...
              'Area',fdata(3),...
              'Hemisphere',fdata(7));

end