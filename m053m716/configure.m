function configure(type)
%CONFIGURE Workspace "environment" configuration for running batch scripts
%
%  Syntax
%     configure(type);
%
%  Example
%     configure('MFR');
%        -> 'MFR_in' is "import" parameters (only)
%     configure('Mxc');
%        -> 'Mxc_in' is "import" parameters (only)
%
% Inputs
%  type  - Char or string: 'MFR' | 'Mxc' | 'MFR_in' | 'Mxc_in'
%
% Output
%  No variables returned; instead, variables are assigned in base
%  workspace.
%
% See also: assignin, mtb, Contents

% % % START: MFR Parameters % % %

% % % Spike rate observations threshold % % %
MFR_THRESH = [0.0025, 50]; % Bounds on activity
% % % % % % % % % % % % % % % % % % % % % % %
% Statistical model parameters
MFR_GLME_MODEL_RESPONSE = "LMFR";
MFR_GLME_MODEL_SPEC = sprintf("%s~1+Treatment*Day*Epoch+(1+Day+logPulses*Epoch|Rat_ID)",MFR_GLME_MODEL_RESPONSE);
MFR_GLME_DIST = 'normal';
MFR_GLME_LINK = 'identity'; 
MFR_GLME_FIT_METHOD = 'Laplace'; % 'REMPL' | 'Laplace' | 'ApproximateLaplace'
MFR_SPREADSHEET_LONG_NAME = "Exports/FR_stats_C_long.xlsx";

% % % END: MFR Parameters % % %

% % % START: I/O Correlation Parameters % % %
MXC_THRESH = exp([-7.4 0]); % [lower, upper] bounds on Mxc (upper-bound of zero == 1 on non-log-transformed corr value)

% Statistical model parameters
IO_GLME_MODEL_RESPONSE = "logMxc";
IO_GLME_MODEL_SPEC = sprintf("%s~1+Treatment*Day+(1+Day+logPulses|Rat_ID)",IO_GLME_MODEL_RESPONSE);
IO_GLME_DIST = 'normal';
IO_GLME_LINK = 'identity'; 
IO_GLME_FIT_METHOD = 'REMPL'; % 'REMPL' | 'Laplace' | 'ApproximateLaplace'
IO_SPREADSHEET_LONG_NAME = "Exports/IO_stats_long.xls";
% % % END: I/O Correlation Parameters % % %

STIM_PULSE_FILE = 'nPulses_Formatted.xlsx';

switch lower(string(type))
   case "mfr"
      LOCAL_MODEL_NAME = "GLME_LMFR.mat"; % Change this if altering models
      REPORT_TAG = "FINAL"; % Change this to "tag" reports with fixed name prepended

      % Data I/O parameters (probably won't change)
      SPREADSHEET_SHEET = "FR_stats_C_long";
      SPREADSHEET_ROWS = [2, 29434];
      LOCAL_TABLE_NAME = "MFR_Table.mat";
      FORCE_RELOAD = false;  % Set true to force to reload from file (for example to regenerate with new MFR threshold)
      FORCE_RERUN = false;   % Set true to force rerun of model estimator even if file is present
      REPORT_NAME = "Reports/GLME_FR_Stats_Export";
      FIGURE_FOLDER = 'Figures';
      
      batch_assign(MFR_THRESH,MFR_GLME_MODEL_RESPONSE,MFR_GLME_MODEL_SPEC,MFR_GLME_DIST,MFR_GLME_LINK,...
         MFR_GLME_FIT_METHOD,LOCAL_MODEL_NAME,REPORT_TAG,MFR_SPREADSHEET_LONG_NAME,...
         SPREADSHEET_SHEET,SPREADSHEET_ROWS,LOCAL_TABLE_NAME,FORCE_RELOAD,FORCE_RERUN,...
         REPORT_NAME,FIGURE_FOLDER);
   case "mfr_in"
      SPREADSHEET_SHEET = "FR_stats_C_long";
      SPREADSHEET_ROWS = [2, 29434];
      batch_assign(MFR_SPREADSHEET_LONG_NAME,SPREADSHEET_SHEET,SPREADSHEET_ROWS,MFR_THRESH);
   case "mxc"
      LOCAL_MODEL_NAME = "GLME_IO-CORR.mat"; % Change this if altering models
      REPORT_TAG = "FINAL"; % Change this to "tag" reports with fixed name prepended

      % Data I/O parameters (probably won't change, except
      %  IO_SPREADSHEET_LONG_NAME): 
      SPREADSHEET_SHEET = "Sheet1";
      SPREADSHEET_ROWS = [2, 6917];
      FORCE_RELOAD = true;  % Set true to force to reload from file (for example to regenerate with new MFR threshold)
      FORCE_RERUN = true;   % Set true to force rerun of model estimator even if file is present
      REPORT_NAME = "Reports/GLME_IO_Stats_Export";
      FIGURE_FOLDER = 'Figures';
      
      batch_assign(MXC_THRESH,IO_GLME_MODEL_RESPONSE,IO_GLME_MODEL_SPEC,...
         IO_GLME_DIST,IO_GLME_LINK,IO_GLME_FIT_METHOD,LOCAL_MODEL_NAME,REPORT_TAG,...
         IO_SPREADSHEET_LONG_NAME,SPREADSHEET_SHEET,SPREADSHEET_ROWS,FORCE_RELOAD,...
         FORCE_RERUN,REPORT_NAME,FIGURE_FOLDER);
   case "mxc_in"
      SPREADSHEET_SHEET = "Sheet1";
      SPREADSHEET_ROWS = [2, 6917];
      batch_assign(IO_SPREADSHEET_LONG_NAME, SPREADSHEET_SHEET, SPREADSHEET_ROWS, MXC_THRESH);
   case "nstims_in"
      assignin('caller','STIM_PULSE_FILE',STIM_PULSE_FILE);
   otherwise
      error('Unrecognized `type`: %s',type);
end

   function batch_assign(varargin)
      for iV = 1:numel(varargin)
         mtb(inputname(iV),varargin{iV});
      end
   end

end