%MFR_STATS_TRENDS Main script for exporting GLME statistical models for MFR
%
%  Replace MFR_SPREADSHEET_LONG_NAME with local version of spreadsheet to
%  import. Note that you may need to change the input option for the number
%  of rows (SPREADSHEET_ROWS). The MFR minimum threshold is set by
%  MFR_THRESH.
%
%  NOTE: Because of how the exported report works, for best results drag
%  the window frames on left and right side of editor to make the Command
%  Window and window containing this script as wide as possible. This makes
%  it less-likely that tables have columns kicked down to the next line.

clc;
clearvars -except T

%% CHANGE PARAMETERS HERE
% % % Spike rate observations threshold % % %
MFR_THRESH = 0.1;
% % % % % % % % % % % % % % % % % % % % % % %

% Statistical model parameters
MFR_GLME_MODEL_SPEC = "MFR~1+Treatment*Day*Epoch+(1+Day+nPulses|Rat_ID)";
MFR_GLME_DIST = 'Gamma';
MFR_GLME_LINK = -1; % Should correspond to canonical link for MFR_GLME_DIST
MFR_GLME_FIT_METHOD = 'REMPL'; % 'REMPL' | 'Laplace' | 'ApproximateLaplace'

LOCAL_MODEL_NAME = "GLME_MFR.mat"; % Change this if altering models
REPORT_TAG = "Basic"; % Change this to "tag" reports with fixed name prepended

% Data I/O parameters (probably won't change)
MFR_SPREADSHEET_LONG_NAME = "Exports/FR_stats_C_long.xlsx";
SPREADSHEET_SHEET = "FR_stats_C_long";
SPREADSHEET_ROWS = [2, 29434];
LOCAL_TABLE_NAME = "MFR_Table.mat";
FORCE_RELOAD = true;  % Set true to force to reload from file (for example to regenerate with new MFR threshold)
FORCE_RERUN = true;   % Set true to force rerun of model estimator even if file is present
REPORT_NAME = "Reports/GLME_FR_Stats_Export";
FIGURE_FOLDER = 'Figures';
FIGURE_NAME = 'MFR - GLME - Fitted Residuals';

%% Import data (if needed)
if exist('T','var')==0 || ~istable(T) || FORCE_RELOAD
   tic;
   if (exist(LOCAL_TABLE_NAME,'file')~=0) || FORCE_RELOAD
      T = importFRstats(...
         MFR_SPREADSHEET_LONG_NAME,...
         SPREADSHEET_SHEET,...
         SPREADSHEET_ROWS,...
         MFR_THRESH);
      % Save it locally to reload it more easily next time.
      save(LOCAL_TABLE_NAME,'T','-v7.3');
      fprintf(1,'Saved table locally to <strong>%s</strong> (%5.2f sec)\n',...
         LOCAL_TABLE_NAME,toc);
   else
      fprintf(1,'Found local data table. Loading <strong>%s</strong>...',...
         LOCAL_TABLE_NAME);
      T = getfield(load(LOCAL_TABLE_NAME,'T'),'T');
      fprintf(1,'complete (%5.2f sec)\n',toc);
   end
else
   fprintf(1,'Found `T` in local workspace. Using existing table.\n');
end

%% Run statistical model
tic;
if exist(LOCAL_MODEL_NAME,'file')==0 || FORCE_RERUN
   fprintf(1,'Please wait, fitting GLME (<strong>"%s"</strong>)...',...
      MFR_GLME_MODEL_SPEC);
   warning('off','stats:classreg:regr:lmeutils:StandardGeneralizedLinearMixedModel:BadDistLinkCombination1');
   glme = fitglme(T,MFR_GLME_MODEL_SPEC,...
      'Distribution',MFR_GLME_DIST,...
      'Link',MFR_GLME_LINK,...
      'Exclude',T.Exclude,...
      'FitMethod',MFR_GLME_FIT_METHOD,...
      'DummyVarCoding','effects'); 
   warning('on','stats:classreg:regr:lmeutils:StandardGeneralizedLinearMixedModel:BadDistLinkCombination1');
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
fname = fullfile(FIGURE_FOLDER,strcat(FIGURE_NAME,REPORT_TAG));
notes = string(...
         sprintf('Report generated on %s\n\n\t->\tMFR Threshold: %5.2f\n\t->\tFitted residuals scatter:\n\t\t\t%s\n',...
            string(datetime()),T.Properties.UserData.MFR_THRESH,fname) ...
         );
if REPORT_TAG~=""
   name = sprintf('%s-%s__%s.txt',REPORT_NAME,REPORT_TAG,string(date()));
else
   name = sprintf('%s__%s.txt',REPORT_NAME,string(date()));
end
exportStats(glme,name,notes);

%% Generate diagnostic figures
fig = plotFittedResiduals(glme);
savefig(fig,strcat(fname,'.fig'));
saveas(fig,strcat(fname,'.eps'));
saveas(fig,strcat(fname,'.png'));
delete(fig);