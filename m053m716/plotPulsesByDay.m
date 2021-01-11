function fig = plotPulsesByDay(T)
%PLOTPULSESBYDAY Plot # stimulus pulses by day
%
%  fig = plotPulsesByDay(T);
%
% Inputs
%  T   - Table (see: importFRstats)
%
% Output
%  fig - Figure handle
%
% See also: Contents, mfr_stats_trends.m

fig = default.figure('Stimulus Pulses by Day',...
   'Width',0.5,'Height',0.4);
ax = default.axes(fig,'XLabel','Postoperative Day',...
   'YLabel','Stimulus Pulses','Title','Pulses by Day',...
   'XLim',[5 27],'XTick',[7 14 21],'YScale','log');
g = ["ADS","RS"];
c = default.Colors();
for ii = 1:numel(g)
   idx = string(T.Treatment)==g(ii) & ~T.Exclude;
   scatter(ax,T.Day(idx),T.nPulses(idx),...
      'MarkerFaceColor',c.(g(ii)),...
      'MarkerEdgeColor',c.(g(ii)),...
      'MarkerFaceAlpha',0.15,...
      'MarkerEdgeAlpha',0.25,...
      'Marker','o',...
      'SizeData',T.MFR(idx).^2,...
      'DisplayName',g(ii));
end
legend(ax,'Location','best');

end