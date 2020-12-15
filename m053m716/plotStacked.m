function [fig,s] = plotStacked(TT,varargin)
%PLOTSTACKED Return stacked time-series of response variate by animal
%
%  [fig,s] = plotStacked(TT);
%  [fig,s] = plotStacked(TT,varargin);
%
% Inputs
%  TT - Timetable (see data2timetable)
%  varargin - (Optional) 'Name',value pairs (see: stackedplot)
%
% Output
%  fig - Figure handle
%  s   - StackedLineChart object
%
% See also: Contents, STACKEDPLOT, TIMETABLE

[pars,varargin] = parseInputs(varargin{:}); 

fig = default.figure('Stacked Response Means','Width',0.6,'Height',0.4);
s = stackedplot(TT,...
   'DisplayLabels',string(TT.Properties.UserData.Key.Treatment),...
   'FontName','Arial',...
   'FontSize',14,...
   'LineWidth',1.5,varargin{:});

for ii = 1:numel(s.AxesProperties)
   s.AxesProperties(ii).YLimits = pars.YLim;
   s.LineProperties(ii).Color = validatecolor(...
      pars.Color.(string(TT.Properties.UserData.Key.Treatment(ii))));
end

   function [pars,varargin] = parseInputs(varargin)
      %PARSEINPUTS Handle parsing of optional inputs for Axes labels
      %
      %  [pars,varargin] = parseInputs(varargin);
      pars = struct;
      pars.Color = default.Colors();
      pars.YLim = [0 0.125];
      fn = fieldnames(pars);
      rmVec = [];
      for iArg = 1:2:numel(varargin)
         idx = strcmpi(fn,varargin{iArg});
         if sum(idx) == 1
            pars.(fn{idx}) = varargin{iArg+1};
            rmVec = [rmVec, iArg, iArg+1]; %#ok<AGROW>
         end
      end
      varargin(rmVec) = [];
   end

end