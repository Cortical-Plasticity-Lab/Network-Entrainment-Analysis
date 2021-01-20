%IOCORR_STAT_TRENDS Main script for exporting GLME statistical models for I/O Correlation results
%
%  Replace IO_SPREADSHEET_LONG_NAME with local version of spreadsheet to
%  import. Note that you may need to change the input option for the number
%  of rows (SPREADSHEET_ROWS).
%
%  NOTE: Because of how the exported report works, for best results drag
%  the window frames on left and right side of editor to make the Command
%  Window and window containing this script as wide as possible. This makes
%  it less-likely that tables have columns kicked down to the next line.
%
% See also: Contents, main.m, mfr_stats_trends.m

close all force;
clear;
clc;

%% CHANGE PARAMETERS HERE
configure('Mxc'); % Exports workspace variables for MFR (defaults)
% Overwrite any outputs here, e.g.
%  FORCE_RERUN = true;

%% Import data table
T = importIOstats(IO_SPREADSHEET_LONG_NAME, SPREADSHEET_SHEET, SPREADSHEET_ROWS, MXC_THRESH);
T.Epoch = repmat("Stim",size(T,1),1); % For the plotting functions only, does not actually mean anything here.

%% Make figure of input distribution
fig = plotInputDistribution(T.Mxc,T.Properties.UserData.MXC_THRESH,...
   'BinEdges',linspace(0,1,1001),'XScale','linear',...
   'XLabel','C_{max}');
set(gca,'XLim',[-0.01, 0.2]);
default.savefig(fig,fullfile(FIGURE_FOLDER,'IO - GLME - Mxc Input Distribution'));

fig = plotInputDistribution(T.logMxc,log(T.Properties.UserData.MXC_THRESH),...
   'BinEdges',linspace(-12,0,1001),'XScale','linear',...
   'XLabel','log(C_{max})');
default.savefig(fig,fullfile(FIGURE_FOLDER,'IO - GLME - LOG-Mxc Input Distribution'));

%% Run statistical model
tic;
if exist(LOCAL_MODEL_NAME,'file')==0 || FORCE_RERUN
   fprintf(1,'Please wait, fitting GLME (<strong>"%s"</strong>)...',...
      IO_GLME_MODEL_SPEC);
   glme = fitglme(T,IO_GLME_MODEL_SPEC,...
      'Distribution',IO_GLME_DIST,...
      'Link',IO_GLME_LINK,...
      'Exclude',T.Exclude,...
      'FitMethod',IO_GLME_FIT_METHOD,...
      'DummyVarCoding','effects'); 
   fprintf(1,'saving locally (<strong>"%s"</strong>)...',LOCAL_MODEL_NAME);
   save(LOCAL_MODEL_NAME,'glme','-v7.3');
   fprintf(1,'complete (%5.2f sec)\n',toc);
else
   fprintf(1,'Found local GLME model. Loading <strong>%s</strong>...',...
      LOCAL_MODEL_NAME);
   glme = getfield(load(LOCAL_MODEL_NAME,'glme'),'glme');
   fprintf(1,'complete (%5.2f sec)\n',toc);
end


%% Export generated report
fname = fullfile(FIGURE_FOLDER,strcat('IO-Corr - GLME - Fitted Residuals',REPORT_TAG));
notes = string(...
         sprintf('Report generated on %s\n\n\t->\tMXC Bounds: [%6.4f < MXC <= %6.4f] \n\t->\tFitted residuals scatter:\n\t\t\t%s\n',...
            string(datetime()),T.Properties.UserData.MXC_THRESH,fname) ...
         );
if REPORT_TAG~=""
   name = sprintf('%s-%s__%s.txt',REPORT_NAME,REPORT_TAG,string(date()));
else
   name = sprintf('%s__%s.txt',REPORT_NAME,string(date()));
end
exportStats(glme,name,notes);

%% Generate diagnostic figures
fig = plotFittedResiduals(glme);
default.savefig(fig,fullfile(FIGURE_FOLDER,'IO-Corr - GLME - Fitted Residuals'),REPORT_TAG);

%% Rerun after excluding detected outliers
T.Exclude = T.Exclude | isoutlier(glme.Residuals.Raw);
tic;
LOCAL_MODEL_NAME2 = strrep(LOCAL_MODEL_NAME,".mat","_refit.mat");
if exist(LOCAL_MODEL_NAME2,'file')==0 || FORCE_RERUN
   fprintf(1,'Please wait, fitting GLME (<strong>"%s"</strong>)...',...
      IO_GLME_MODEL_SPEC);
   tmp = fitglme(T,IO_GLME_MODEL_SPEC,...
      'Distribution',IO_GLME_DIST,...
      'Link',IO_GLME_LINK,...
      'Exclude',T.Exclude,...
      'FitMethod',IO_GLME_FIT_METHOD,...
      'DummyVarCoding','effects'); 
   fprintf(1,'complete (%5.2f sec)\n',toc);
   
   iIter = 2;
   while any(isoutlier(tmp.Residuals.Raw))
      iIter = iIter + 1;
      T.Exclude = T.Exclude | isoutlier(tmp.Residuals.Raw);
      tic;
      fprintf(1,'Removing outliers: iteration %d...',iIter);
      tmp = fitglme(T,IO_GLME_MODEL_SPEC,...
         'Distribution',IO_GLME_DIST,...
         'Link',IO_GLME_LINK,...
         'Exclude',T.Exclude,...
         'FitMethod',IO_GLME_FIT_METHOD,...
         'DummyVarCoding','effects'); 
      fprintf(1,'complete (%5.2f sec)\n',toc);
   end
   glme2 = tmp;
   fprintf(1,'Saving locally (<strong>"%s"</strong>)...',LOCAL_MODEL_NAME2);
   save(LOCAL_MODEL_NAME2,'glme2','-v7.3');
   fprintf(1,'complete (%5.2f sec)\n',toc);
else
   fprintf(1,'Found local GLME model. Loading <strong>%s</strong>...',...
      LOCAL_MODEL_NAME2);
   glme2 = getfield(load(LOCAL_MODEL_NAME2,'glme'),'glme');
   fprintf(1,'complete (%5.2f sec)\n',toc);
end
notes = string(sprintf(...
   'GLME refit after secondary outlier exclusion (n = %d observations removed)',...
      sum(isoutlier(glme2.Residuals.Raw))));
if REPORT_TAG~=""
   name = sprintf('%s-%s-refit__%s.txt',REPORT_NAME,REPORT_TAG,string(date()));
else
   name = sprintf('%s-refit__%s.txt',REPORT_NAME,string(date()));
end
exportStats(glme2,name,notes);

%% Generate diagnostic figures
fig = plotFittedResiduals(glme2);
default.savefig(fig,fullfile(FIGURE_FOLDER,'IO-Corr - GLME - Residuals after refit'),REPORT_TAG);

%% Generate trend plot (STIM-only)
groupings = {'RS','Stim';'ADS','Stim'};
fig = exportTrendPlots(glme2,'Stim',glme2.ResponseName,groupings);
ax = findobj(fig.Children,'Type','Axes');
for ii = 1:numel(ax)
   if strcmpi(ax(ii).YScale,'linear')
      set(ax(ii),'YLim',[-10 5]);
   end
end
default.savefig(fig,fullfile(FIGURE_FOLDER,'IOCorr - GLME'));

%% Random Effects
data = printRandomEffects(glme);
writetable(data,'GLME-Mxc_Random-Effects.xlsx');