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
MXC_THRESH = exp([-7.4 0]); % [lower, upper] bounds on Mxc (upper-bound of zero == 1 on non-log-transformed corr value)

% Statistical model parameters
IO_GLME_MODEL_RESPONSE = "logMxc";
IO_GLME_MODEL_SPEC = sprintf("%s~1+Treatment*Day+(1+Day+Day_Sigmoid+logPulses|Rat_ID)",IO_GLME_MODEL_RESPONSE);
IO_GLME_DIST = 'normal';
IO_GLME_LINK = 'identity'; 
IO_GLME_FIT_METHOD = 'ApproximateLaplace'; % 'REMPL' | 'Laplace' | 'ApproximateLaplace'

LOCAL_MODEL_NAME = "GLME_LOG_IO-CORR.mat"; % Change this if altering models
REPORT_TAG = "_LOG"; % Change this to "tag" reports with fixed name prepended

% Data I/O parameters (probably won't change, except
%  IO_SPREADSHEET_LONG_NAME): 
IO_SPREADSHEET_LONG_NAME = "Exports/IO_stats_long.xls";
SPREADSHEET_SHEET = "Sheet1";
SPREADSHEET_ROWS = [2, 6917];
FORCE_RELOAD = true;  % Set true to force to reload from file (for example to regenerate with new MFR threshold)
FORCE_RERUN = true;   % Set true to force rerun of model estimator even if file is present
REPORT_NAME = "Reports/GLME_IO_Stats_Export";
FIGURE_FOLDER = 'Figures';

%% Import data table
T = importIOstats(IO_SPREADSHEET_LONG_NAME, SPREADSHEET_SHEET, SPREADSHEET_ROWS, MXC_THRESH);

%% Make figure of input distribution
fig = plotInputDistribution(T.Mxc,T.Properties.UserData.MXC_THRESH,...
   'BinEdges',linspace(-0.1,1.1,1001),'XScale','linear');
default.savefig(fig,fullfile(FIGURE_FOLDER,'IO - GLME - Mxc Input Distribution - Linear'));

fig = plotInputDistribution(T.Mxc,T.Properties.UserData.MXC_THRESH,...
   'BinEdges',linspace(0,0.2,101),'XScale','log');
default.savefig(fig,fullfile(FIGURE_FOLDER,'IO - GLME - Mxc Input Distribution - Log-Inset'));

fig = plotInputDistribution(T.logMxc,log(T.Properties.UserData.MXC_THRESH),...
   'BinEdges',linspace(-12,0,1001),'XScale','linear');
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
         sprintf('Report generated on %s\n\n\t->\tMXC Bounds: [%5.2f < MXC <= %5.2f] \n\t->\tFitted residuals scatter:\n\t\t\t%s\n',...
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

% Input stimuli distributions
[~,TID] = findgroups(T(:,{'Rat_ID','Treatment'}));
fig = plotStimsByAnimal(T.logPulses(~T.Exclude),T.Rat_ID(~T.Exclude),TID);
default.savefig(fig,fullfile(FIGURE_FOLDER,'Distribution of Stimuli by Rat'),REPORT_TAG);
