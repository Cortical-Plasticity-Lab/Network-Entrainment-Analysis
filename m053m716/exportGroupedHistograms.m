function fig = exportGroupedHistograms(Y,THRESH,varargin)
%EXPORTBARCHART Export bar chart for Figure 4 by-area comparisons
%
%   fig = exportGroupedHistograms(Y,THRESH);
%   fig = exportGroupedHistograms(Y,THRESH,'Name',value,...);
%
% Inputs
%   Y - Aggregate table with cell 'data' variable.
%   THRESH - Threshold set during pixel inclusion
%   varargin - (Optional) 'Name',value pairs for `bar` object
%
% Output
%   fig - Figure handle
%
% See also: main.m

% First properties table
Group = ["SHAM"; "ADS"; "RS"];
Color = [0 0 0; 0 0 1; 1 0 0];
P1 = table(Group,Color);

fig = figure(...
    'Name','Grouped Intensity Histograms',...
    'Color','w',...
    'PaperOrientation','portrait',...
    'Units','Normalized',...
    'PaperUnits','inches',...
    'PaperSize',[8.5 11],...
    'Position',[0.3 0.1 0.4 0.8]);

nRow = 11;
nCol = 4;

% Group data
Y.ID = string(strcat(string(Y.Name),":",string(Y.Hemisphere),":",string(Y.Area)));
edges = 0:2:250;
xl = [edges(1), edges(end)];
x = edges(1:(end-1)) + mean(diff(edges))/2;

for ii = 1:size(Y,1)
    ax = subplot(nRow,nCol,ii);
    set(ax,'NextPlot','add','XColor','k','YColor','k','LineWidth',1.5,...
        'Tag',Y.ID(ii),'FontName','Arial','XLim',xl);
    title(ax,Y.ID(ii),'FontName','Arial','Color','k');
    y = histcounts(Y.data{ii},edges);
    c = P1.Color(P1.Group==string(Y.Group{ii}),:);
    bar(ax,x,y,'EdgeColor','none','FaceColor',c);
    line(ax,ones(1,2).*THRESH(1),ax.YLim,'LineStyle',':','Color','#333','LineWidth',2);
    line(ax,ones(1,2).*THRESH(2),ax.YLim,'LineStyle',':','Color','#555','LineWidth',2);
end

end