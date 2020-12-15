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

fig = default.figure('Input Stimuli Distributions');
groupings = ["ADS"; "RS"; "C"];

if ~ismember("C",string(TID.Treatment))
   groupings = groupings(1:2);
   nRow = 2;
else
   nRow = 3;
end
nCol = 5; % 5 is maximum group size

obj = [];
xl = [inf, -inf];
yl = [inf, -inf];

for iG = 1:nRow
   inGroup = TID.Rat_ID(string(TID.Treatment) == groupings(iG));
   iGroup = ismember(rat_ID_vals,inGroup);
   r = rat_ID_vals(iGroup);
   u = unique(r);
   for iU = 1:numel(u)
      idx = r == u(iU);
      iPlot = nCol * (iG - 1) + iU;
      ax = subplot(nRow,nCol,iPlot);
      set(ax,'LineWidth',1.25,'XColor','k','YColor','k',...
         'NextPlot','add','FontName','Arial','FontSize',12,...
         'XScale',pars.XScale,'YScale',pars.YScale);
      
      default.histogram(ax,pulse_vals(idx));
      ax.UserData = pulse_vals(idx);
      title(ax,string(u(iU)),'FontName','Arial','FontSize',15,'FontWeight','bold');
      
      if iU == 1
         ylabel(ax,sprintf(pars.YLabel,groupings(iG)),...
            'FontName','Arial','FontSize',13,'FontWeight','bold');
      end
      
      if iG == nRow
         xlabel(ax,pars.XLabel,...
            'FontName','Arial','FontSize',13,'FontWeight','bold');
      end
      obj = [obj; ax]; %#ok<AGROW>
      xl = [min(xl(1),ax.XLim(1)), max(xl(2),ax.XLim(2))];
      yl = [min(yl(1),ax.YLim(1)), max(yl(2),ax.YLim(2))];
   end 
end

if isempty(pars.XLim)
   pars.XLim = xl;
end

if isempty(pars.YLim)
   pars.YLim = yl;
end

for ii = 1:numel(obj)
   set(obj(ii),'XLim',pars.XLim,'YLim',pars.YLim);
   delete(obj(ii).Children);
   default.histogram(obj(ii),obj(ii).UserData,...
      'BinEdges',linspace(xl(1),xl(2),pars.NBins));
end

   function [pars,varargin] = parseInputs(varargin)
      %PARSEINPUTS Handle parsing of optional inputs for Axes labels
      %
      %  [pars,varargin] = parseInputs(varargin);
      pars = struct;
      pars.NBins = 21;
      pars.XLabel = 'Stimuli';
      pars.XLim = [];
      pars.XScale = 'log';
      pars.YLabel = 'Count (%s)';
      pars.YLim = [0 500];
      pars.YScale = 'linear';
%       pars.YTick = [1 10 100 1000];
%       tmpTick = sprintf('10^{%d}:',log10(pars.YTick));
%       pars.YTickLabels = strsplit(tmpTick(1:(end-1)),':');
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