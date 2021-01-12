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
configure('MFR'); % Exports workspace variables for MFR (defaults)
% Overwrite any outputs here, e.g.
%  FORCE_RERUN = true;

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
% fig = plotInputDistribution(T.MFR,T.Properties.UserData.MFR_THRESH,'BinEdges',linspace(0,100,2001));
% default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution'));
% 
% fig = plotInputDistribution(T.SMFR,[min(T.SMFR(~T.Exclude)), max(T.SMFR(~T.Exclude))],...
%    'BinEdges',linspace(0,12,8001),'XLabel','MFR \surd(normalized spikes/sec)',...
%    'XScale','log');
% default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution - SMFR'));

fig = plotInputDistribution(T.LMFR,[min(T.LMFR(~T.Exclude)), max(T.LMFR(~T.Exclude))],...
   'BinEdges',linspace(-8,6,8001),'XLabel','MFR log(normalized spikes/sec)',...
   'XScale','linear');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution - LMFR'));

% fig = plotInputDistribution(T.omega,[min(T.omega(~T.Exclude)), max(T.omega(~T.Exclude))],...
%    'BinEdges',linspace(0,7,8001),'XLabel','\omega (normalized spikes/sec)',...
%    'XScale','log');
% default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Input Distribution - Omega'));

%% Run statistical model
tic;
if exist(LOCAL_MODEL_NAME,'file')==0 || FORCE_RERUN
   fprintf(1,'Please wait, fitting GLME (<strong>"%s"</strong>)...',...
      MFR_GLME_MODEL_SPEC);
   glme = fitglme(T,MFR_GLME_MODEL_SPEC,...
      'Distribution',MFR_GLME_DIST,...
      'Link',MFR_GLME_LINK,...
      'Exclude',T.Exclude,...
      'FitMethod',MFR_GLME_FIT_METHOD,...
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
fname = fullfile(FIGURE_FOLDER,strcat('MFR - GLME - Fitted Residuals',REPORT_TAG));
notes = string(...
         sprintf('Report generated on %s\n\n\t->\tMFR Bounds: [%6.4f < MFR <= %6.4f] spikes/sec\n\t->\tFitted residuals scatter:\n\t\t\t%s\n',...
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
% % Only needs to be run once: % %
fig = exportTrendPlots(T,'Pre');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Trends by Epoch - Pre'));

fig = exportTrendPlots(T,'Stim');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Trends by Epoch - Stim'));

fig = exportTrendPlots(T,'Post');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - GLME - Trends by Epoch - Post'));

%% Generate summary figures: marginal values (fixed-effects from model only)
[fig,T_marg] = exportMarginalTrendPlots(glme,'Pre');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - MARGINAL-GLME - Trends by Epoch - Pre'));

fig = exportMarginalTrendPlots(glme,'Stim');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - MARGINAL-GLME - Trends by Epoch - Stim'));

fig = exportMarginalTrendPlots(glme,'Post');
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - MARGINAL-GLME - Trends by Epoch - Post'));

%% Get dependence on number of stimuli
fig = plotResponseStimsRelation(glme);
default.savefig(fig,fullfile(FIGURE_FOLDER,'MFR - MARGINAL-GLME - Stim-Response Relations - Stim'));

%% Random Effects
data = printRandomEffects(glme);
writetable(data,'GLME-MFR_Random-Effects.xlsx');

%% Post-hoc T-tests
[pVal,F,DF1,DF2] = reportCoefTest(glme,1:3,1:14); % 1:14 are not 3-way interaction term