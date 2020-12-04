%% MAIN  Main script for exporting stats on AA synaptophysin (round 2)
clear; close all; clc;

%% MAIN CONFIGURATION VARIABLE
% This must point to the data folder (DIR)
DIR = 'G:/Lab Member Folders/Page Hayley/Max Data/AA synaptophysin';

%% (other configuration variables)
EXPORT_NAME = sprintf('Exports/IntensityStatsTable__%s',string(date()));
REPORT_NAME_STRING = 'Reports/GLME_Report__%s.txt';
FIG_OUTPUT = 'Figures';

%% AGGREGATE THE DATA
F = dir(fullfile(DIR,'*.tif'));
maintic = tic;
fprintf(1,'\nRetrieving ALL masked pixels...');
[data,meta] = getMaskedPixelData(F);
fprintf(1,'complete\n');

%% SUB-SAMPLE AND EXPORT A DATA TABLE FOR STATS
N = 50000;

Value = [];
Hemisphere = [];
Name = [];
Area = [];
Group = [];

fprintf(1,'\nConcatenating table (using <strong>N = %d</strong>)...\n',N);
for ii = 1:numel(data)
   n = numel(data{ii});
   k = min(N,numel(data{ii}));
   fprintf(1,'->\t%s:%s-%s...',meta(ii).Name,meta(ii).Hemisphere,meta(ii).Area);
   
   Name = [Name; repmat(string(meta(ii).Name),k,1)]; %#ok<*AGROW>
   Group = [Group; repmat(string(meta(ii).Group),k,1)];
   Hemisphere = [Hemisphere; repmat(string(meta(ii).Hemisphere),k,1)];
   Area = [Area; repmat(string(meta(ii).Area),k,1)];
   
   % Draw without replacement
   val = data{ii}(randsample(n,k,false));
   Value = [Value; val(:)];
   fprintf(1,'complete\n');   
end
fprintf(1,'\nTable complete.\n\n');
T = table(Name,Group,Hemisphere,Area,Value);
exportName = getExportName(EXPORT_NAME);
% writetable(T,exportName); % Export only works well with limited # of
%                           % sub-samples due to limitations of Spreadsheet size.
toc(maintic);

%% Export figure of input distribution
fig = exportHistogram(T.Value);
savefig(fig,fullfile(FIG_OUTPUT,'Figure 4 - Intensity Distribution Raw.fig'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Intensity Distribution Raw.eps'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Intensity Distribution Raw.png'));
delete(fig);

%% Run Statistics
tic;
fprintf(1,'Please wait, fitting log(Poisson) GLME for pixel intensity values...');
glme = fitglme(T,'Value~Group*Hemisphere*Area+(1+Hemisphere*Area|Name)',...
    'FitMethod','REMPL','Link','log','Distribution','Poisson');
fprintf(1,'complete (%5.2f sec)\n',toc);
pause(2);

%% Create Statistics Export
clc;
disp(glme);
disp('<strong>R-squared:</strong>');
disp(glme.Rsquared);
disp('<strong>ANOVA:</strong>');
disp(anova(glme));

out = command_window_text();
fname_export = sprintf(REPORT_NAME_STRING,string(date()));
if exist(fname_export,'file')~=0
    delete(fname_export);
end
fid = fopen(fname_export,'w');
for ii = 1:numel(out)
   fprintf(fid,'%s\n',out{ii}); 
end
fclose(fid);

%% Make diagnostic plots
fig = figure('Name','Fitted Residuals',...
    'Color','w','PaperOrientation','portrait','PaperSize',[8.5 11],...
    'PaperUnits','inches'); 
plotResiduals(glme,'fitted');
set(get(gca,'XLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'YLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'Title'),'FontName','Arial','FontSize',20,'Color','k','FontWeight','bold');
set(gca,'LineWidth',1.5,'XColor','k','YColor','k');
savefig(fig,fullfile(FIG_OUTPUT,'Figure 4 - Fitted Residuals.fig'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Fitted Residuals.eps'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Fitted Residuals.png'));
delete(fig);

fig = figure('Name','Histogram of Residuals',...
    'Color','w','PaperOrientation','portrait','PaperSize',[8.5 11],...
    'PaperUnits','inches'); 
plotResiduals(glme);
set(get(gca,'XLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'YLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'Title'),'FontName','Arial','FontSize',20,'Color','k','FontWeight','bold');
set(gca,'LineWidth',1.5,'XColor','k','YColor','k');
savefig(fig,fullfile(FIG_OUTPUT,'Figure 4 - Histogram of Residuals.fig'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Histogram of Residuals.eps'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Histogram of Residuals.png'));
delete(fig);

%% CROSS-TABULATE DATA TO GET COUNTS BY ANIMAL OF INCLUDED PIXELS
clc;
[G,X] = findgroups(T(:,{'Name','Group','Hemisphere','Area'}));
X.N = splitapply(@numel,T.Value,G);
disp(X);

%% Export cross-tabulation result
writetable(X,'Exports/Cross-Tabulation.xlsx');
nTotalCount = cellfun(@numel,data,'UniformOutput',true);
Y = struct2table(meta);
Y.NTotal = nTotalCount;
writetable(Y,'Exports/Total-ROI-Pixel-Tabulation.xlsx');

%% Generate grouped bar plot as {LH S1, LH RFA, RH S1, RH RFA}
fig = exportBarChart(T);
savefig(fig,fullfile(FIG_OUTPUT,'Figure 4 - Bar Chart of Means.fig'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Bar Chart of Means.eps'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Bar Chart of Means.png'));
delete(fig);

