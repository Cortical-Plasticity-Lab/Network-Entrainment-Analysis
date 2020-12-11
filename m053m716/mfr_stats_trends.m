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

close all force;
clearvars -except T
clc;

%% CHANGE PARAMETERS HERE
% % % Spike rate observations threshold % % %
MFR_THRESH = [0.0025, 50]; % Bounds on activity
% % % % % % % % % % % % % % % % % % % % % % %

% Statistical model parameters
MFR_GLME_MODEL_RESPONSE = "LMFR";
MFR_GLME_MODEL_SPEC = sprintf("%s~1+Treatment*Day*Epoch+(1+Day+Day_Sigmoid+nPulses|Rat_ID)",MFR_GLME_MODEL_RESPONSE);
MFR_GLME_DIST = 'normal';
MFR_GLME_LINK = 'identity'; 
MFR_GLME_FIT_METHOD = 'Laplace'; % 'REMPL' | 'Laplace' | 'ApproximateLaplace'

LOCAL_MODEL_NAME = "GLME_LMFR_log-normal_non-sigmoid-days.mat"; % Change this if altering models
REPORT_TAG = "log-normal_non-sigmoid-days"; % Change this to "tag" reports with fixed name prepended

% Data I/O parameters (probably won't change)
MFR_SPREADSHEET_LONG_NAME = "Exports/FR_stats_C_long.xlsx";
SPREADSHEET_SHEET = "FR_stats_C_long";
SPREADSHEET_ROWS = [2, 29434];
LOCAL_TABLE_NAME = "MFR_Table.mat";
FORCE_RELOAD = true;  % Set true to force to reload from file (for example to regenerate with new MFR threshold)
FORCE_RERUN = true;   % Set true to force rerun of model estimator even if file is present
REPORT_NAME = "Reports/GLME_FR_Stats_Export";
FIGURE_FOLDER = 'Figures';

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

%% Make figure of input distribution
fig = plotInputDistribution(T.MFR,T.Properties.UserData.MFR_THRESH,'BinEdges',linspace(0,100,2001));
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution'));

fig = plotInputDistribution(T.SMFR,[min(T.SMFR(~T.Exclude)), max(T.SMFR(~T.Exclude))],...
   'BinEdges',linspace(0,12,8001),'XLabel','MFR \surd(normalized spikes/sec)',...
   'XScale','log');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution - SMFR'));

fig = plotInputDistribution(T.LMFR,[min(T.LMFR(~T.Exclude)), max(T.LMFR(~T.Exclude))],...
   'BinEdges',linspace(-8,6,8001),'XLabel','MFR log(normalized spikes/sec)',...
   'XScale','linear');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution - LMFR'));

fig = plotInputDistribution(T.omega,[min(T.omega(~T.Exclude)), max(T.omega(~T.Exclude))],...
   'BinEdges',linspace(0,7,8001),'XLabel','\omega (normalized spikes/sec)',...
   'XScale','log');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution - Omega'));

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
fname = fullfile(FIGURE_FOLDER,strcat('MFR - GLME - Fitted Residuals',REPORT_TAG));
notes = string(...
         sprintf('Report generated on %s\n\n\t->\tMFR Bounds: [%5.2f < MFR <= %5.2f] spikes/sec\n\t->\tFitted residuals scatter:\n\t\t\t%s\n',...
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
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Fitted Residuals'),REPORT_TAG);

%% Generate summary figures
fig = exportTrendPlots(T,'Pre');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Trends by Epoch - Pre'));

fig = exportTrendPlots(T,'Stim');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Trends by Epoch - Stim'));

fig = exportTrendPlots(T,'Post');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Trends by Epoch - Post'));

