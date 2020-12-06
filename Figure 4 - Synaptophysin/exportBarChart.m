function [fig,P1,P2] = exportBarChart(T,varargin)
%EXPORTBARCHART Export bar chart for Figure 4 by-area comparisons
%
%   fig = exportBarChart(T);
%   fig = exportBarChart(T,'Name',value,...);
%   [fig,P1,P2] = ... 
%
% Inputs
%   T - Data table from `IntensityStatsTable.xlsx`
%   varargin - (Optional) 'Name',value pairs for `bar` object
%
% Output
%   fig - Figure handle
%   [P1,P2] - Return first and second properties tables also.
%
% See also: main.m

% First properties table
pars = struct;
pars.Group = ["SHAM"; "ADS"; "RS"];
pars.Color = [0 0 0; 0 0 1; 1 0 0];
pars.Offset = [-0.5; 0; 0.5];
% Second properties table
pars.ID = ["LH S1"; "LH RFA"; "RH S1"; "RH RFA"];
pars.XTick = [1;3;5;7];
% Other properties
pars.ErrorType = 'STD'; % 'SD' or 'STD' | 'SEM'

fn = fieldnames(pars);
for iV = 1:2:numel(varargin)
   idx = strcmpi(fn,varargin{iV});
   if sum(idx)==1
      pars.(fn{idx}) = varargin{iV+1};
   end
end


P1 = table(pars.Group,pars.Color,pars.Offset);
P2 = table(pars.ID,pars.XTick);
P1.Properties.VariableNames = {'Group','Color','Offset'};
P2.Properties.VariableNames = {'ID','XTick'};

fig = figure(...
    'Name','Average pixel intensity By Area',...
    'Color','w',...
    'PaperOrientation','portrait',...
    'Units','Normalized',...
    'PaperUnits','inches',...
    'PaperSize',[8.5 11],...
    'Position',[0.3 0.3 0.29 0.38]);

ax = axes(fig,'XColor','k','YColor','k','NextPlot','add',...
    'LineWidth',1.5,'FontName','Arial','FontSize',16,...
    'XTick',P2.XTick,'XLim',[0 8],...
    'XTickLabels',P2.ID);
ylabel(ax,'Mean Pixel Intensity',...
    'FontName','Arial','Color','k','FontSize',16);

% Group data
T.ID = strcat(T.Hemisphere," ",T.Area);
[G,TID] = findgroups(T(:,{'ID','Group'}));
TID.Mean = splitapply(@nanmean,T.Value,G);

switch upper(pars.ErrorType)
   case {'SD','STD','STANDARD DEVIATION'}
      pars.ErrorType = 'STD';
      TID.STD = splitapply(@(x)nanstd(x,[],1),T.Value,G);
   case {'SEM','SE','STANDARD ERROR', 'STANDARD ERROR OF THE MEAN'}
      pars.ErrorType = 'SEM';
      TID.SEM = splitapply(@(x)nanstd(x,[],1)/sqrt(numel(x)),T.Value,G);
   otherwise
      error('Unrecognized value of `ErrorType`: %s',pars.ErrorType);
end

for ii = 1:size(P1,1)
    t = TID(TID.Group==P1.Group(ii),:);
    t = outerjoin(t,P2,'Type','left',...
        'LeftVariables',{'ID','Group','Mean',pars.ErrorType},...
        'RightVariables',{'XTick'},...
        'Keys',{'ID'});
    t.X = t.XTick + P1.Offset(ii);
    bar(ax,t.X,t.Mean,...
        'EdgeColor','none',...
        'FaceColor',P1.Color(ii,:),...
        'DisplayName',P1.Group(ii),...
        'Tag',P1.Group(ii),'BarWidth',0.20);
    h = errorbar(t.X,t.Mean,-t.(pars.ErrorType)*0.5,t.(pars.ErrorType)*0.5,...
        'Parent',ax,...
        'LineWidth',1.5,'Color','m','LineStyle','none',...
        'DisplayName',sprintf('1 %s',pars.ErrorType));
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
h.Annotation.LegendInformation.IconDisplayStyle = 'on';
legend(ax,'FontName','Arial','TextColor','black','EdgeColor','none',...
    'FontSize',13,'FontWeight','bold');
end