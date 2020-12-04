%% MAIN  Main script for exporting stats on AA synaptophysin (round 2)
clear; close all; clc;


%%
DIR = 'G:\Lab Member Folders\Page Hayley\Max Data\AA synaptophysin';
EXPORT_NAME = 'IntensityStatsTable';

F = dir(fullfile(DIR,'*.tif'));

maintic = tic;
fprintf(1,'\nRetrieving ALL masked pixels...');
[data,meta] = getMaskedPixelData(F);
fprintf(1,'complete\n');

%% SUB-SAMPLE AND EXPORT A DATA TABLE FOR STATS
N = 1000;

Value = [];
Hemisphere = [];
Name = [];
Area = [];
Group = [];

fprintf(1,'\nConcatenating table...\n');
for ii = 1:numel(data)
   n = numel(data{ii});
   k = min(N,numel(data));
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

writetable(T,exportName);
toc(maintic);

%% Run Statistics
clc;
tic;
fprintf(1,'Please wait, fitting log(Poisson) GLME for pixel intensity values...');
glme = fitglme(T,'Value~Group*Hemisphere*Area+(1+Hemisphere*Area|Name)',...
    'FitMethod','REMPL','Link','log','Distribution','Poisson');
fprintf(1,'complete (%5.2f sec)\n',toc);

disp(glme);
disp('<strong>R-squared:</strong>');
disp(glme.Rsquared);
disp('<strong>ANOVA:</strong>');
disp(anova(glme));

out = command_window_text();
fid = fopen(sprintf('GLME_Report__%s.txt',string(date())),'w');
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
savefig(fig,'Figure 4 - Fitted Residuals.fig');
saveas(fig,'Figure 4 - Fitted Residuals.eps');
saveas(fig,'Figure 4 - Fitted Residuals.png');
delete(fig);

fig = exportHistogram(T.Value);
savefig(fig,'Figure 4 - Intensity Distribution Raw.fig');
saveas(fig,'Figure 4 - Intensity Distribution Raw.eps');
saveas(fig,'Figure 4 - Intensity Distribution Raw.png');
delete(fig);

fig = figure('Name','Histogram of Residuals',...
    'Color','w','PaperOrientation','portrait','PaperSize',[8.5 11],...
    'PaperUnits','inches'); 
plotResiduals(glme);
set(get(gca,'XLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'YLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'Title'),'FontName','Arial','FontSize',20,'Color','k','FontWeight','bold');
set(gca,'LineWidth',1.5,'XColor','k','YColor','k');
savefig(fig,'Figure 4 - Histogram of Residuals.fig');
saveas(fig,'Figure 4 - Histogram of Residuals.eps');
saveas(fig,'Figure 4 - Histogram of Residuals.png');
delete(fig);
