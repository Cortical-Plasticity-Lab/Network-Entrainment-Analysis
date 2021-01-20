function fig = plotPulsesByDay(T,sz)
%PLOTPULSESBYDAY Plot # stimulus pulses by day
%
%  fig = plotPulsesByDay(T);
%
% Inputs
%  T   - Table (see: importFRstats)
%  sz  - Column vector with same # elements as rows of T, to be used for
%           size of each "bubble". If not included, then if T has 'MFR' as
%           a variable it is used. Otherwise, if T has 'Mxc', it is used.
%           Otherwise, default value for each element is set to 48 (points)
%           -> If Mxc or MFR are used, then 
%              * MFR: Value is squared
%              * Mxc: Value is multiplied by 10 and then squared.
%
% Output
%  fig - Figure handle
%
% See also: Contents, mfr_stats_trends.m

DEF_SIZE = 48;
YLIM = [0 60000];

fig = default.figure('Stimulus Pulses by Day',...
   'Width',0.5,'Height',0.4);
ax = default.axes(fig,...
   'XLabel','Postoperative Day',...
   'YLabel','Stimulus Pulses',...
   'Title','Pulses by Day',...
   'XLim',[5 27],'XTick',[7 14 21],...
   'YScale','linear','YLim',YLIM);
g = ["ADS","RS"];
c = default.Colors();
if (nargin < 2)
   if ismember('MFR',T.Properties.VariableNames)
      sz = (max(T.MFR,2)).^2;
      face_alpha_in = 0.15;
      edge_alpha_in = 0.25;
      face_alpha_out = 0;
      edge_alpha_out = 0.15;
   elseif ismember('Mxc',T.Properties.VariableNames)
      sz = (max(T.Mxc,0.2).*64).^2;
      face_alpha_in = 0.10;
      edge_alpha_in = 0.20;
      face_alpha_out = 0;
      edge_alpha_out = 0.15;
   else
      sz = ones(size(T,1),1).*DEF_SIZE;
      face_alpha_in = 0.65;
      edge_alpha_in = 0.15;
      face_alpha_out = 1;
      edge_alpha_out = 1;
   end
else
   face_alpha_in = 0.75;
   edge_alpha_in = 0.25;
   face_alpha_out = face_alpha_in;
   edge_alpha_out = edge_alpha_in;
end
if ismember('Epoch',T.Properties.VariableNames)
   iKeep = T.Epoch == "Stim";
else
   iKeep = true(size(T,1),1);
end

for ii = 1:numel(g)
   idx = string(T.Treatment)==g(ii) & ~T.Exclude & iKeep;
   scatter(ax,T.Day(idx),T.nPulses(idx),...
      'MarkerFaceColor',c.(g(ii)),...
      'MarkerEdgeColor',c.(g(ii)),...
      'MarkerFaceAlpha',face_alpha_in,...
      'MarkerEdgeAlpha',edge_alpha_in,...
      'Marker','o',...
      'SizeData',sz(idx),...
      'DisplayName',sprintf('%s (included)',g(ii)));
   idx = string(T.Treatment)==g(ii) & T.Exclude;
   scatter(ax,T.Day(idx),T.nPulses(idx),...
      'Marker','x',...
      'MarkerFaceColor',c.(g(ii)),...
      'MarkerEdgeColor',c.(g(ii)),...
      'LineWidth',2.5,...
      'MarkerFaceAlpha',face_alpha_out,...
      'MarkerEdgeAlpha',edge_alpha_out,...
      'SizeData',sz(idx),...
      'DisplayName',sprintf('%s (excluded)',g(ii)));
end
legend(ax,'Location','best');

end