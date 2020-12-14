function fig = plotFittedResiduals(glme)
%PLOTFITTEDRESIDUALS Generate fitted residuals plot for `fitglme` result
%
%  fig = plotFittedResiduals(glme);
%
% Inputs
%  glme - Result from Matlab `fitglme`
%
% Output
%  fig  - Figure handle
%
% See also: Contents, main.m, mfr_stats_trends.m

fig = default.figure('GLME Residuals','Width',0.6,'Height',0.4);
[ax,x,y] = default.axes(subplot(1,2,1));
plotResiduals(glme,'fitted','ResidualType','Pearson');
set(x,'FontWeight','bold','Color','k');
set(y,'FontWeight','bold','Color','k');

f = glme.Fitted;
r = glme.Residuals.Raw;
idx = isoutlier(r);
scatter(ax,f(idx),r(idx),'Marker','o','SizeData',14,'LineWidth',1.5,...
   'Marker','o','MarkerFaceColor','none','MarkerEdgeColor','r',...
   'DisplayName','Outlier');

[~,x,y] = default.axes(subplot(1,2,2));
plotResiduals(glme,'histogram','ResidualType','Pearson');
set(x,'String','Residual','Color','k');
set(y,'String','Bin Probability','Color','k');

end