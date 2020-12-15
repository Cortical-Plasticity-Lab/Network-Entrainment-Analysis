function fig = plotResponseStimsRelation(glme)
%PLOTRESPONSESTIMSRELATION  Make figure showing relation of stims and response
%
%  fig = plotResponseStimsRelation(glme);
%
% Inputs
%  glme - GeneralizedLinearMixedModel object returned by `fitglme`
%
% Output
%  fig  - Figure handle
% 
% See also: Contents

S = 30; % Number of points to draw along the interval to evaluate stims

c = default.Colors();
T = glme.Variables;
T(string(T.Treatment)=="C",:) = [];
fig = default.figure('Response-Stims Relations');
ax = default.axes(fig,'XLabel','# Stimuli','XScale','log',...
   'YLabel','log(MFR)','Title','Response-Stims Relations: GLME');

g = unique(T.Treatment);
s = round(logspace(3,5,S))';


for iG = 1:numel(g)
   cThis = c.(string(g(iG)));
   t = T(T.Treatment==g(iG),:);
%    [~,~,bin] = histcounts(t.);
   nSamples = size(t,1);
   Y = cell(S,1);
   for ii = 1:S
      t.logPulses = ones(nSamples,1)*s(ii);
      Y{ii} = predict(glme,t);
   end
   gfx__.plotWithShadedError(ax,s,Y,...
      'FaceColor',cThis,'Color',cThis,...
      'DisplayName',string(g(iG)),'StandardDeviations',0.5,...
      'Tag',string(g(iG)),'Annotation','on');
end
default.legend(ax,'Location','northwest');

end