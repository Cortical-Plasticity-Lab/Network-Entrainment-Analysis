%IMPORT_CORRECTED_NPULSES Import # stimulus pulses

close all force;
clear; clc;
PULSE_Z_THRESH = 2; % For excluding outlier days by group for # pulses

S = readtable('Exports/nPulses.xls');
S.Properties.VariableNames{'Name'} = 'Rat_ID';
S.Rat_ID = categorical(S.Rat_ID);
S.Treatment = categorical(S.Treatment,1:3,["ADS", "RS", "C"]);
S.Day = S.Day + 5; % To account for offset period while rat was recovering
S = doPulseCountExclusion(S,PULSE_Z_THRESH);
disp(head(S)); % Print the first few lines from the table.
writetable(S,'Exports/nPulses_Formatted.xlsx');

%% Plot the number of pulses by animal
% Input stimuli distributions
[~,TID] = findgroups(S(:,{'Rat_ID','Treatment'}));
fig = plotStimsByAnimal(S.nPulses(~S.Exclude),S.Rat_ID(~S.Exclude),TID);
default.savefig(fig,fullfile('Figures','Stims','Distribution of Stimuli by Rat'));

%% Plot number of pulses by day
fig = plotPulsesByDay(S);
default.savefig(fig,fullfile('Figures','Stims','Stimulus counts by Day'));

%% Plot number of pulses by day sized by MFR
configure('MFR_in');
T = importFRstats(MFR_SPREADSHEET_LONG_NAME,SPREADSHEET_SHEET,SPREADSHEET_ROWS,MFR_THRESH);
fig = plotPulsesByDay(T);
default.savefig(fig,fullfile('Figures','Stims','Stimulus counts by Day - MFR'));

%% Plot number of pulses by day sized by Mxc
configure('Mxc_in');
T = importIOstats(IO_SPREADSHEET_LONG_NAME, SPREADSHEET_SHEET, SPREADSHEET_ROWS, MXC_THRESH);
fig = plotPulsesByDay(T);
default.savefig(fig,fullfile('Figures','Stims','Stimulus counts by Day - Mxc'));