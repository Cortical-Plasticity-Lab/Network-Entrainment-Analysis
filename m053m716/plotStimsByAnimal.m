function fig = plotStimsByAnimal(pulse_vals,rat_ID_vals,TID,varargin)
%PLOTSTIMSBYANIMAL Return figure of stimulus random effect input distributions by rat.
%
%  fig = plotStimsByAnimal(pulse_vals,rat_ID_vals,TID);
%  fig = plotStimsByAnimal(pulse_vals,rat_ID_vals,TID,'Name',value,...);
%
% Inputs
%  pulse_vals  - Vector of stimulus pulse values (logPulses or nPulses)
%  rat_ID_vals - Vector of corresponding Rat_ID grouping variable
%  TID         - Groupings table of IDs with variables 'Rat_ID' and
%                 'Treatment' so that each rat goes in the correct row of
%                 the subplots array.
%  varargin    - (Optional) 'Name',value keyword pairs
%
% Output
%  fig         - Input distribution figure handle, with subplots sorted by
%                 rat
%
% See also: Contents

pars = parseInputs(varargin{:});

fig = default.figure('Input Stimuli Distributions',...
   'Position',[1.11 0.12 0.63 0.58]);
groupings = ["ADS"; "RS"; "C"];

if ~ismember("C",string(TID.Treatment))
   groupings = groupings(1:2);
   nRow = 2;
else
   nRow = 3;
end
nCol = 5; % 5 is maximum group size
nPlot = size(TID,1);

xl = [inf, -inf];
yl = [inf, -inf];

TID.obj = cell(size(TID,1),1);
TID.idx = cell(size(TID,1),1);
for iG = 1:nRow
   inGroup = TID.Rat_ID(string(TID.Treatment) == groupings(iG));
   iGroup = ismember(rat_ID_vals,inGroup);
   r = rat_ID_vals(iGroup);
   u = unique(r);
   for iU = 1:numel(u)
      iTable = TID.Rat_ID == u(iU);
      TID.idx{iTable} = r == u(iU);
      iPlot = nCol * (iG - 1) + iU;
      ax = subplot(nRow,nCol,iPlot);
      set(ax,'LineWidth',1.25,'XColor','k','YColor','k',...
         'NextPlot','add','FontName','Arial','FontSize',12,...
         'XScale',pars.XScale,'YScale',pars.YScale,...
         'XTick',[],'TickDir','both');
      
      default.histogram(ax,pulse_vals(TID.idx{iTable}));
      title(ax,string(u(iU)),'FontName','Arial','FontSize',15,'FontWeight','bold');
      
      if (iU == 1)
%          ylabel(ax,sprintf(pars.YLabel,groupings(iG)),...
%             'FontName','Arial','FontSize',13,'FontWeight','bold');
         ylabel(ax,pars.YLabel,...
            'FontName','Arial','FontSize',13,'FontWeight','bold');
         set(ax,'Tag',sprintf('%s.YLabel',ax.Tag));
      else
         set(ax,'YTick',[]);
      end
      
      if (iPlot > (nPlot - nCol))
         xlabel(ax,pars.XLabel,...
            'FontName','Arial','FontSize',13,'FontWeight','bold');
         set(ax,'Tag',sprintf('%s.XLabel',ax.Tag));
      end
      TID.obj{iTable} = ax;
      xl = [min(xl(1),ax.XLim(1)), max(xl(2),ax.XLim(2))];
      yl = [min(yl(1),ax.YLim(1)), max(yl(2),ax.YLim(2))];
   end 
end

if isempty(pars.XLim)
   pars.XLim = xl;
   pars.XTick = xl;
   pars.XTickLabel = cell(1,2);
   for ii = 1:2
      pars.XTickLabel{ii} = sprintf('%dk',round(xl(ii)/1000));
   end
end

if isempty(pars.YLim)
   pars.YLim = yl;
end

cols = default.Colors();

for ii = 1:size(TID,1)
   set(TID.obj{ii},'XLim',pars.XLim,'YLim',pars.YLim);
   delete(TID.obj{ii}.Children);
   if contains(TID.obj{ii}.Tag,'XLabel')
      set(TID.obj{ii},'XTick',pars.XTick,'XTickLabel',pars.XTickLabel);
   end
   default.histogram(TID.obj{ii},pulse_vals(TID.idx{ii}),...
      'BinEdges',linspace(xl(1),xl(2),pars.NBins),...
      'FaceColor',cols.(string(TID.Treatment(ii))),...
      'EdgeColor',cols.(string(TID.Treatment(ii))),...
      'DisplayName',string(TID.Treatment(ii)));
   if contains(TID.obj{ii}.Tag,'YLabel')
      default.legend(TID.obj{ii});
   end
end

   function [pars,varargin] = parseInputs(varargin)
      %PARSEINPUTS Handle parsing of optional inputs for Axes labels
      %
      %  [pars,varargin] = parseInputs(varargin);
      pars = struct;
      pars.NBins = 21;
      pars.XLabel = '# Stimuli';
      pars.XLim = [];
      pars.XScale = 'log';
      pars.XTick = [];
      pars.XTickLabel = {};
      pars.YLabel = '# Recordings';
      pars.YLim = [0 20];
      pars.YScale = 'linear';
      fn = fieldnames(pars);
      rmVec = [];
      for iV = 1:2:numel(varargin)
         iArg = strcmpi(fn,varargin{iV});
         if sum(iArg) == 1
            pars.(fn{iArg}) = varargin{iV+1};
            rmVec = [rmVec, iV, iV+1]; %#ok<AGROW>
         end
      end
      varargin(rmVec) = [];
   end

end