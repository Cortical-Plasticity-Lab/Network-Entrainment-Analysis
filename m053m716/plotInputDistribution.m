function [fig,N,edges,h,l] = plotInputDistribution(x,thresh,varargin)
%PLOTINPUTDISTRIBUTION Plot input distribution of x
%
%  fig = plotInputDistribution(x,thresh);
%  [fig,N,edges,h,l] = plotInputDistribution(ax,x,thresh,'Name',value,...);
%
%     -> e.g. 
%     fig = plotInputDistribution(T.MFR,MFR_THRESH);
%
% Inputs
%  x      - Vector of input data (responses, or predictors)
%  thresh - [lower, upper] thresholds (optional)
%
% Output
%  fig    - Figure handle
%  N      - Bin counts
%  edges  - Bin edges vector
%  h      - Handle to two histogram objects. First object is "in-bounds"
%              histogram, while second is "out-of-bounds" histogram.
%  l      - Two-element handle vector; first element is lowerbound line,
%           second element is upper-bound line (for bounds set by `thresh`)
%
% See also: Contents, main.m mfr_stats_trends.m

switch nargin
   case 1
      if ~isa(x,'matlab.graphics.axis.Axes')
         [pars,varargin] = parseInputs(varargin{:});
         thresh = [nan,nan];
         fig = default.figure('Input Distribution');
         ax = default.axes(fig,...
            'Tag','Histogram',...
            'XScale',pars.XScale,...
            'YScale',pars.YScale,...
            'XLabel',pars.XLabel,...
            'YLabel',pars.YLabel,...
            'Title',pars.Title);
      else
         error('No data supplied.');
      end
   case 2
      if ~isa(x,'matlab.graphics.axis.Axes')
         [pars,varargin] = parseInputs(varargin{:});
         fig = default.figure('Input Distribution');
         ax = default.axes(fig,...
            'Tag','Histogram',...
            'XScale',pars.XScale,...
            'YScale',pars.YScale,...
            'XLabel',pars.XLabel,...
            'YLabel',pars.YLabel,...
            'Title',pars.Title);
      else
         fig = x.Parent;
         ax = x;
         x = thresh;
         thresh = [nan, nan];
      end
   otherwise
      if ~isa(x,'matlab.graphics.axis.Axes')
         [pars,varargin] = parseInputs(varargin{:});
         fig = default.figure('Input Distribution');
         ax = default.axes(...
            fig,...
            'Tag','Histogram',...
            'XScale',pars.XScale,...
            'YScale',pars.YScale,...
            'XLabel',pars.XLabel,...
            'YLabel',pars.YLabel,...
            'Title',pars.Title);
      else
         fig = x.Parent;
         ax = x;
         x = thresh;
         thresh = varargin{1};
         varargin(1) = [];
      end
end

v = default.histogram(ax,x,...
   'DisplayName','Input Distribution',...
   varargin{:},'Visible','off'); % First, get invisible. 
% Use this to split into two objects: "in-bounds" and "out-of-bounds"
%  -> Indicate differences by coloring them.

edges = v.BinEdges;
centers = edges(1:(end-1)) + mean(diff(edges)); % Should be uniformly-spaced

delete(v);
N = histcounts(x,edges);

iLow = edges(2:end) < thresh(1);
iHigh = edges(1:(end-1)) >= thresh(2);
iOut = iLow | iHigh;

inName = sprintf('\\color{darkGreen}\\bfIncluded\\rm\\color{black} Input Data \\color{darkGreen}(\\bf{%4.1f%%})',...
   100*sum(N(~iOut))/numel(x));
inbounds = default.bar(ax,centers(~iOut),N(~iOut),1,...
   'DisplayName',inName,...
   'Tag','Included-Bar');
outName = sprintf('Excluded Input Data (%4.1f%%)',...
   100*sum(N(iOut))/numel(x));
outofbounds = default.bar(ax,centers(iOut),N(iOut),0.95,...
   'DisplayName',outName,...
   'Tag','Excluded-Bar',...
   'FaceColor','#ff6600',...
   'EdgeColor','#803100',...
   'FaceAlpha',0.25,...
   'EdgeAlpha',0.5,...
   'LineWidth',1.5);
h = [inbounds; outofbounds];
lb = default.line(ax,ones(1,2).*thresh(1),ax.YLim*0.67,...
   'Color','#4d004d','LineStyle',':',...
   'MarkerIndices',1,'Marker','v','MarkerFaceColor','k',...
   'LineWidth',2.5,...
   'DisplayName',sprintf('Lower Threshold (%5.2f)',thresh(1)),...
   'Tag','Lower-Bound');
lb.Annotation.LegendInformation.IconDisplayStyle = 'on';
ub = default.line(ax,ones(1,2).*thresh(2),ax.YLim*0.67,...
   'Color','#ff66ff','LineStyle',':',...
   'MarkerIndices',2,'Marker','^','MarkerFaceColor','#ddd',...
   'LineWidth',2.5,...
   'DisplayName',sprintf('Upper Threshold (%5.2f)',thresh(2)),...
   'Tag','Upper-Bound');
ub.Annotation.LegendInformation.IconDisplayStyle = 'on';
l = [lb; ub];
default.legend(ax,'Location','northoutside','NumColumns',2);

   function [pars,varargin] = parseInputs(varargin)
      %PARSEINPUTS Handle parsing of optional inputs for Axes labels
      pars = struct;
      pars.XLabel = 'MFR (spikes/sec)';
      pars.XScale = 'log';
      pars.YLabel = 'Count';
      pars.YScale = 'linear';
      pars.Title  = 'Input Distribution';
      fn = fieldnames(pars);
      rmVec = [];
      for iV = 1:2:numel(varargin)
         idx = strcmpi(fn,varargin{iV});
         if sum(idx) == 1
            pars.(fn{idx}) = varargin{iV+1};
            rmVec = [rmVec, iV, iV+1]; %#ok<AGROW>
         end
      end
      varargin(rmVec) = [];
   end

end