%% MAIN  Main script for exporting stats on AA synaptophysin (round 2)
clear; close all; clc;

%% MAIN CONFIGURATION VARIABLE
% Name of local pixel intensity file. If it does not exist, it is created
% after the first extraction. This is used to speed up subsequent loads
% without having to re-extract the pixel data from source. If you require
% re-extraction, change the filename here or delete this file locally.
LOCAL_PIXEL_INTENSITY_DATA_FILE = 'IntensityData.mat';

% If no local data file exists, this points to the "server" (or general
% file folder) containing the *.tiff files from which pixel intensities
% were extracted.
DIR = 'Q:/Lab Member Folders/Page Hayley/Max Data/AA synaptophysin';

% [LOWER, UPPER] pixel intensity bounds. 
%  For a given integer describing pixel intensity (`Value`) this sets the
%  upper and lower bounds extracted from pixels included by the binary mask
%  by requiring that each `x` in Value satisfies {LOWER <= x < UPPER}
THRESH = [1 100];
                  
   
% This is a string used to tag notes about a particular run configuration. 
% It is included in the exported statistics *.txt file.
NOTES = sprintf(strcat("06-Dec-2020\n", ...
   "\tSwitched from log(Poisson) to inverse-link Gamma.\n", ...
   "\tChanged DummyVarCoding from 'reference' to 'effects'.\n")); 
                  
%% (other configuration variables)
EXPORT_NAME = sprintf('Exports/IntensityStatsTable__%s',string(date()));
REPORT_NAME_STRING = 'Reports/GLME_Report__%s.txt';
FIG_OUTPUT = 'Figures';

%% AGGREGATE THE DATA
F = dir(fullfile(DIR,'*.tif'));
maintic = tic;
[data,meta] = getMaskedPixelData(F,THRESH,LOCAL_PIXEL_INTENSITY_DATA_FILE);

%% SUB-SAMPLE AND EXPORT A DATA TABLE FOR STATS
N = 5000;

Value = [];
Hemisphere = [];
Name = [];
Area = [];
Group = [];

fprintf(1,'\nConcatenating table (using <strong>N = %d</strong>)...\n',N);
for ii = 1:numel(data)
   n = numel(data{ii});
   k = min(N,n);
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
fprintf(1,'Please wait, fitting <strong>inverse-link Gamma</strong> GLME for pixel intensity values...');
glme = fitglme(T,'Value~1+Group*Hemisphere*Area+(1+Hemisphere*Area|Name)',...
    'FitMethod','REMPL',...
    'Link',-1,...
    'Distribution','Gamma',...
    'DummyVarCoding','effects');
fprintf(1,'complete (%5.2f sec)\n',toc);

%% Create Statistics Export
clc;
fprintf(1,'--- <strong>NOTES</strong> ---\n\n');
fprintf(1,'%s\n',NOTES);
fprintf(1,'-- <strong>END NOTES</strong> --\n\n');
fprintf(1,'--- <strong>MODEL</strong> ---\n\n');
disp(glme);
disp('<strong>R-squared:</strong>');
disp(glme.Rsquared);
fprintf(1,'\n-- <strong>END MODEL</strong> --\n\n');
fprintf(1,'--- <strong>ANOVA</strong> ---\n');
disp(anova(glme));
fprintf(1,'\n-- <strong>END ANOVA</strong> --\n\n');
pause(2);

[~,raw,~] = command_window_text();
fname_export = sprintf(REPORT_NAME_STRING,string(date()));
if exist(fname_export,'file')~=0
    delete(fname_export);
end
fid = fopen(fname_export,'w');
fprintf(fid,'**GLME: %s**\n%s',string(date()),raw); 
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
Y.data = data;

%% Export per-grouping histograms
fig = exportGroupedHistograms(Y,THRESH);
savefig(fig,fullfile(FIG_OUTPUT,'Figure 4 - Grouped Intensity Histograms.fig'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Grouped Intensity Histograms.eps'));
saveas(fig,fullfile(FIG_OUTPUT,'Figure 4 - Grouped Intensity Histograms.png'));
delete(fig);

%% Generate grouped bar plot as {LH S1, LH RFA, RH S1, RH RFA}
ErrorType = {'STD','SEM','Image','Location','Rat','Treatment'};
for ii = 1:numel(ErrorType)
   figName = sprintf('Figure 4 - Bar Chart of Means - Error is %s',ErrorType{ii});
   fig = exportBarChart(Y,'ErrorType',ErrorType{ii});
   savefig(fig,fullfile(FIG_OUTPUT,[figName '.fig']));
   saveas(fig,fullfile(FIG_OUTPUT,[figName '.eps']));
   saveas(fig,fullfile(FIG_OUTPUT,[figName '.png']));
   delete(fig);
end

