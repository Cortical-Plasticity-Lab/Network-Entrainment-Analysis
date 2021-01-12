function T = doPulseCountExclusion(T,thresh)
%DOPULSECOUNTEXCLUSION Add 'Exclude' to Table based on log(# pulse counts)
%
%  T = doPulseCountExclusion(T);
%  T = doPulseCountExclusion(T,thresh);
%
% Inputs
%  T - Data table that has 'nPulses' column as well as 'Treatment' column
%  thresh - (Optional) exclusion threshold (z-score) default is 2 (we
%                 expect # pulses to be "well-behaved" within-group)
%
% Output
%  T - Data table with 'Exclude' column but otherwise same as input.
%
% See also: Contents, import_corrected_nPulses.m

if nargin < 2
   thresh = 2;
end

T.Exclude = false(size(T,1),1);
[G,TID] = findgroups(T(:,'Treatment'));
for ii = 1:size(TID,1)
   idx = G == ii;
   z = zscore(log(T.nPulses(idx)));
   T.Exclude(idx) = abs(z) > thresh;
end

fprintf(1,'\nExcluded <strong>%d</strong> of %d recordings due to # Stimuli\n\n',...
   sum(T.Exclude),size(T,1));

end