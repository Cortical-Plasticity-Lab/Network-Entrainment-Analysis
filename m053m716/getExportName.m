function exportName = getExportName(baseName)
%% GETEXPORTNAME  Checks this path for file, to prevent over-write of data
%
%  exportName = GETEXPORTNAME(baseName);
%
% By: Max Murphy  v1.0  2019-07-19  Original version (R2017a)

%%
ii = 0;
exportName = sprintf('%s_%02g.xlsx',baseName,ii);
while exist(exportName,'file')~=0
   ii = ii + 1;
   exportName = sprintf('%s_%02g.xlsx',baseName,ii);
end

end