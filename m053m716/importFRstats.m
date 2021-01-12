function T = importFRstats(workbookFile, sheetName, dataLines, MFR_THRESH)
%IMPORTFRSTATS Import data from a spreadsheet
%  T = IMPORTFRSTATS(FILE) reads data from the first worksheet in the
%  Microsoft Excel spreadsheet file named FILE.  Returns the data as a
%  table.
%
%  T = IMPORTFRSTATS(FILE, SHEET) reads from the specified worksheet.
%
%  T = IMPORFRSTATS(FILE, SHEET, DATALINES) reads from the specified
%  worksheet for the specified row interval(s). Specify DATALINES as a
%  positive scalar integer or a N-by-2 array of positive scalar integers
%  for dis-contiguous row intervals.
%
%  T = IMPORFRSTATS(FILE, SHEET, DATALINES, MFR_THRESH) 
%  reads from the specified
%  worksheet for the specified row interval(s). Specify DATALINES as a
%  positive scalar integer or a N-by-2 array of positive scalar integers
%  for dis-contiguous row intervals.
%  Specify MFR_THRESH to set bounds on acceptable mean firing rate (default
%  is [0.1, 10], spikes/sec).
%
%  Example:
%  T = importFRstats("D:\Downloads\FR_stats_C_long.xlsx", "FR_stats_C_long", [2, 29434]);
%
%  See also: Contents, READTABLE.
%
% Auto-generated by MATLAB on 10-Dec-2020 09:13:59

%% Input handling
configure('nstims_in');

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
   sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2 || isempty(dataLines)
   dataLines = [2, 29434];
end

if nargin <= 3
   MFR_THRESH = [0.1, 10];
end

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 6);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":F" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["Day", "Name", "Stim", "nPulses", "Time", "MFR"];
opts.VariableTypes = ["double", "categorical", "categorical", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, ["Name", "Stim"], "EmptyFieldRule", "auto");

% Import the data
T = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
   opts.DataRange = "A" + dataLines(idx, 1) + ":F" + dataLines(idx, 2);
   tb = readtable(workbookFile, opts, "UseExcel", false);
   T = [T; tb]; %#ok<AGROW>
end
c = (1:(size(T,1)/3))'; % Make "pseudo-ID" for each channel. Grouped as three-in-a-row PRE STIM POST values
T.Pseudo_Channel_ID = repelem(c,3,1);
T.Properties.VariableNames{'Name'} = 'Rat_ID';
T.Properties.VariableNames{'Time'} = 'Epoch';
T.Epoch = ordinal(T.Epoch,{'Pre','Stim','Post'});
T.Properties.VariableNames{'Stim'} = 'Treatment';
[T.Day_Sigmoid,T.Day] = transformations.Day(T.Day);

[p,~,~] = fileparts(workbookFile);
S = readtable(fullfile(p,STIM_PULSE_FILE));
T.Rat_ID = string(T.Rat_ID);
S.Rat_ID = string(S.Rat_ID);
T = outerjoin(T,S,'Type','left',...
   'Keys',{'Rat_ID','Day'},...
   'LeftVariables',setdiff(T.Properties.VariableNames,'nPulses'),...
   'RightVariables',{'nPulses','Exclude'});
T.Rat_ID = categorical(T.Rat_ID);

% Exclude any observations with MFR outside of fixed bounds
exc = (T.MFR <= MFR_THRESH(1)) | (T.MFR > MFR_THRESH(2)) | isnan(T.nPulses);
T.Exclude = T.Exclude | exc; 

% When assigning pulses by day, the pulses originated only from the Stim
% epochs. However, we did the outerjoin by rat and day. Set the pulses
% during non-Stim epochs to zero:
uEpoch = unique(T.Epoch);
for ii = 1:numel(uEpoch)
   iEpoch = T.Epoch==uEpoch(ii);
   if uEpoch(ii)~="Stim"
      T.nPulses(iEpoch) = zeros(sum(iEpoch),1);
   end
end

% Get unique groupings by rat, channel, day: 
g = {'Rat_ID','Pseudo_Channel_ID','Day'};
[G,TID] = findgroups(T(:,g));
TID.Exclude = splitapply(@any,T.Exclude,G);


T = outerjoin(T,TID,'Type','left','Keys',g,...
   'LeftVariables',setdiff(T.Properties.VariableNames,'Exclude'),...
   'RightVariables',{'Exclude'});
T.N = round(T.MFR*60*60); % "scale to corresponding N of spikes"
[T.SMFR,T.LMFR,T.omega] = transformations.MFR(T.MFR,MFR_THRESH(2));
T.logPulses = transformations.Stimulus_Count(T.nPulses);

% Move things so column order makes more sense:
T = movevars(T,'logPulses','after','nPulses');
T = movevars(T,{'LMFR','SMFR'},'after','MFR');
T = movevars(T,{'Treatment','Rat_ID'},'before',1);
T = movevars(T,'Exclude','after',size(T,2));
T = movevars(T,'Epoch','after','Day');
T = movevars(T,'Pseudo_Channel_ID','after','Day');

T.Properties.Description = "Mean firing rate (MFR) data for chronic statistical model testing differences in rate induced by ADS, RS, or Control stimulation, while accounting for total stimulation.";

T.Properties.VariableDescriptions{'Day'} = 'Relative Day after Implantation Surgery';
T.Properties.VariableDescriptions{'Rat_ID'} = 'Rat Identifier (RYY-#, where R denotes rat surgery; YY is last two digits of year, # is relative surgery within that year at cortical plasticity lab)';
T.Properties.VariableDescriptions{'Treatment'} = 'Stimulation treatment group: activity-dependent stimulation (ADS), random-stimulation (RS), or control (C)';
T.Properties.VariableDescriptions{'Pseudo_Channel_ID'} = 'Unique Channel/Session Identifier';
T.Properties.VariableDescriptions{'nPulses'} = 'Total number of pulses within that stimulation epoch';
T.Properties.VariableUnits{'nPulses'} = 'icms pulses';
T.Properties.VariableDescriptions{'logPulses'} = 'Logarithmic transformation on number of pulses. For controls, value is estimate of matched-epoch value across all such epochs in RS or ADS observations.';
T.Properties.VariableUnits{'logPulses'} = 'log(icms pulses)';
T.Properties.VariableDescriptions{'Epoch'} = 'Within-session treatment epoch: "Pre" (30-minutes), "Stim" (80-minutes), or "Post" (90-minutes)';
T.Properties.VariableDescriptions{'MFR'} = 'Mean firing rate (average number of spikes per second during that epoch)';
T.Properties.VariableUnits{'MFR'} = 'spikes/second';
T.Properties.VariableDescriptions{'LMFR'} = 'log-transform applied to MFR';
T.Properties.VariableUnits{'LMFR'} = 'log(spikes/second)';
T.Properties.VariableDescriptions{'SMFR'} = 'Square-root transform applied to MFR';
T.Properties.VariableUnits{'SMFR'} = 'sqrt(spikes/second)';
T.Properties.VariableDescriptions{'omega'} = 'MFR divided by two times the upper-bound on rate';
T.Properties.VariableUnits{'omega'} = 'normalized spike frequency';
T.Properties.VariableDescriptions{'N'} = 'Expected integer value of spikes in 60-minutes given observed MFR';
T.Properties.VariableUnits{'N'} = 'extrapolated spikes';
T.Properties.VariableDescriptions{'Exclude'} = sprintf('Insufficient spike observations to include observation with confidence in underlying firing rate of process (true if MFR < %5.2f spikes/sec)',MFR_THRESH);

T.Properties.RowNames = strcat(string(T.Rat_ID),"::",string(T.Treatment),...
   "::D-",num2str(T.Day,'%02d'),...
   "::Ch-",num2str(T.Pseudo_Channel_ID,'%04d'),"-",string(T.Epoch));

% Do cross-tabulation
T.Properties.UserData.MFR_THRESH = MFR_THRESH;
T.Properties.UserData.dataLines = dataLines;
T.Properties.UserData.sheetName = sheetName;
T.Properties.UserData.workbookFile = workbookFile;
T.Properties.UserData.CrossTab = struct;
[T.Properties.UserData.CrossTab.X,T.Properties.UserData.CrossTab.chi2,T.Properties.UserData.CrossTab.p,T.Properties.UserData.CrossTab.labels] = ...
   crosstab(strcat(string(T.Rat_ID(~T.Exclude)),"(",string(T.Treatment(~T.Exclude)),")"),T.Epoch(~T.Exclude));
x = T.Properties.UserData.CrossTab.X;
x = mat2cell(x,size(x,1),ones(1,size(x,2)));
xTab = table(x{:});
xTab.Properties.VariableNames = T.Properties.UserData.CrossTab.labels(1:3,2);
xTab.ID = T.Properties.UserData.CrossTab.labels(:,1);
xTab = movevars(xTab,'ID','before',1);
xTab.ID = categorical(xTab.ID);
xTab.Properties.VariableUnits = {'',...
   'Unique Channel/Session Counts','Unique Channel/Session Counts','Unique Channel/Session Counts'};
T.Properties.UserData.CrossTab.Data = xTab;

fprintf(1,'Observations outside the range <strong>%5.2f <= MFR < %5.2f spikes/sec</strong> are excluded.\n',MFR_THRESH);
fprintf(1,'\t->\tSpike rates in non-excluded observations: [%5.2f - %5.2f] spikes/sec\n',min(T.MFR(~T.Exclude)),max(T.MFR(~T.Exclude)));
fprintf(1,'\t->\tTabulated unique epoch/channel counts (observations) by Animal:\n');
fprintf(1,'\t\t\t<strong>(Note: all columns should have identical counts based on exclusion strategy)</strong>\n\n');
disp(T.Properties.UserData.CrossTab.Data);
fprintf(1,'\n\n-------------------------------------------------------\n\n');

end