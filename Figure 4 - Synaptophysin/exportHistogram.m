function [fig,ax,h,x,y] = exportHistogram(data,varargin)
%EXPORTHISTOGRAM Export histograms for Alberto's data.
%
%   fig = exportHistogram(T);
%   [fig,ax,h,x,y] = exportHistogram(T,'Name',value,...);
%
% Inputs
%   T - Data table from `IntensityStatsTable.xlsx`
%   varargin - (Optional) 'Name',value pairs for `bar` object
%
% Output
%   fig - Figure handle
%   ax  - Axes handle
%   h   - Bar handle
%   x   - X-data (bins)
%   y   - Y-data (bin counts)
%
% See also: main.m

fig = figure(...
    'Name','Pixel Intensities',...
    'Color','w',...
    'PaperOrientation','portrait',...
    'Units','Normalized',...
    'PaperUnits','inches',...
    'PaperSize',[8.5 11],...
    'Position',[0.3 0.3 0.25 0.25]);
ax = axes(fig,'XColor','k','YColor','k','NextPlot','add',...
    'LineWidth',1.5,'FontName','Arial','FontSize',14);
title(ax,'Intensity Values','FontName','Arial','Color','k','FontSize',20,'FontWeight','bold');
xlabel(ax,'Intensity','FontName','Arial','Color','k','FontSize',16);
ylabel(ax,'Pixel Count','FontName','Arial','Color','k','FontSize',16);

[y,edges] = histcounts(data);
x = edges(1:(end-1)) + mean(diff(edges))/2;

h = bar(ax,x,y,...
    'EdgeColor','none',...
    'FaceColor','m',...
    'FaceAlpha',0.8,varargin{:});

end