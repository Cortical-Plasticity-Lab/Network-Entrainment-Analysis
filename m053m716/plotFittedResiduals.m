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

fig = figure('Name','Fitted Residuals',...
    'Color','w','PaperOrientation','portrait','PaperSize',[8.5 11],...
    'PaperUnits','inches'); 
plotResiduals(glme,'fitted');
set(get(gca,'XLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'YLabel'),'FontName','Arial','FontSize',16,'Color','k');
set(get(gca,'Title'),'FontName','Arial','FontSize',20,'Color','k','FontWeight','bold');
set(gca,'LineWidth',1.5,'XColor','k','YColor','k');

end