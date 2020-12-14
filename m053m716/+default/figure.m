function fig = figure(name,varargin)
%FIGURE Return default figure handle
%
%  fig = default.figure(); % -> To use 'Name',value keyword pairs, must
%                          %    provide a value for `name` (can specify as
%                          %    '' to use default)
%  fig = default.figure(name);
%  fig = default.figure(name,'Name',value,...);
%
% Inputs
%  name     - Name of figure ('Name' figure property)
%              -> To skip, assign as empty value ([] or '' or "")
%  varargin - 'Name',value keyword argument pairs for Matlab figure builtin
%                 
% Output
%  fig      - Formatted Matlab figure handle
%
% See also: Contents, matlab.ui.Figure

[pars,varargin] = parseInputs(varargin{:});

if (nargin < 1) || isempty(name) || name==""
   name = "Untitled Figure";
end

r = groot;
if size(r.MonitorPositions,1) > 1
   pos = [(pars.X + 1)  pars.Y  pars.Width  pars.Height];
else
   pos = [pars.X  pars.Y  pars.Width  pars.Height];
end
pos(1:2) = pos(1:2) + randn(1,2).*0.0025; % Jitter figure position

fig = figure(...
   'Name',name,...
   'Units','Normalized',...
   'Position',pos,...
   'Color','w',...
   'PaperOrientation','portrait',...
   'PaperSize',[8.5 11],...
   'PaperUnits','inches',...
   varargin{:}); % Insert the rest as "Name",value keyword pairs

   function [pars,varargin] = parseInputs(varargin)
      %PARSEINPUTS Handle parsing of optional inputs for Axes labels
      %
      %  [pars,varargin] = parseInputs(varargin);
      pars = struct;
      pars.Height = 0.40;
      pars.Width = 0.30;
      pars.X = 0.2;
      pars.Y = 0.25;
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