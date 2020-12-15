function [h,k] = histogram(ax,x,varargin)
%HISTOGRAM Return default histogram object for given axes and data
%
%  h = default.histogram(x); % -> Sets ax using `default.axes()`
%  h = default.histogram(ax,x);
%  h = default.histogram(ax,x,'Name',value,...);
%  [h,k] = ...
%
% Inputs
%  name     - Name of figure ('Name' figure property)
%  varargin - 'Name',value keyword argument pairs for Matlab axes builtin
%                 
% Output
%  h        - Formatted Matlab histogram primitive chart object handle
%  k        - (Optional) if second output is requested, generates smooth
%                 kernel density estimate to superimpose on the histogram.
%
% See also: Contents, matlab.graphics.chart.primitive.Histogram

switch nargin
   case 0
      ax = default.axes();
      x  = nan(1,2);
      name = 'Untitled';
   case 1
      if isa(ax,'matlab.graphics.axis.Axes')
         x = nan(1,2);
         name = ax.Tag;
      elseif isa(ax,'char') || isa(ax,'string')
         varargin = [ax, varargin];
         ax = default.axes();
         x = nan(1,2);
         name = 'Untitled';
      else
         x = ax;
         ax = default.axes();
         name = inputname(1);
      end
   otherwise
      if isa(ax,'matlab.graphics.axis.Axes')
         if ~isnumeric(x)
            varargin = [x, varargin];
            x = nan(1,2);
            name = 'Untitled';
         else
            name = inputname(2);
         end
      elseif isa(ax,'char') || isa(ax,'string')
         varargin = [ax, x, varargin];
         ax = default.axes();
         x = nan(1,2);
         name = 'Untitled';
      else
         varargin = [x, varargin];
         x = ax;
         ax = gca;
         name = inputname(1);
      end
end

h = histogram(ax,x,...
   'Tag',sprintf('Histogram-%02d',numel(ax.Children)+1),...
   'DisplayName',name,...
   'FaceColor','#444',...
   'EdgeColor','#666',...
   'FaceAlpha',0.6,...
   'EdgeAlpha',0.8,...
   varargin{:});

if nargout < 2
   return;
end

if strcmpi(h.FaceColor,'none')
   c = h.EdgeColor;
else
   c = h.FaceColor;
end

ksdensity(ax,x,...
   'Support',h.BinLimits,...
   'BoundaryCorrection','reflection',...
   'NumPoints',h.NumBins+1,...
   'Kernel','epanechnikov',...
   'Function','pdf');
k = findobj(ax.Children,'Type','line');
k = k(1);
set(k,'Color',c,'LineWidth',4);
k.Annotation.LegendInformation.IconDisplayStyle = 'off';
k.Tag = sprintf('%s-KDE',h.Tag);

if strcmpi(h.Normalization,'count')
   delta = nanmean(diff(k.XData));
   N = sum(h.BinCounts);
   xx = k.XData(1:(end-1))+delta/2;
   yy = (k.YData(1:(end-1)) + k.YData(2:end))./2;
   set(k,...
      'XData',[k.XData(1), xx, k.XData(end)],...
      'YData',[0, yy.*delta.*N, 0]);
end

end