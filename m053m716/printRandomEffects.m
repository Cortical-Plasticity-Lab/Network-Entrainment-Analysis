function data = printRandomEffects(glme,alpha)
%PRINTRANDOMEFFECTS Print summary of significant random effects
%
%  data = printRandomEffects(glme);
%  data = printRandomEffects(glme,alpha);
%
% Inputs
%  glme - GeneralizedLinearMixedEffectsModel object
%  alpha - (Optional) statistical significance level threshold. 
%           -> Default value is 0.05
%
% Output
%  data - Data table for significant random effects summary
%
% See also: mfr_stats_trends.m, iocorr_stats_trends.m, Contents

if nargin < 2
   alpha = 0.05;
end

[B,BNames,stats] = randomEffects(glme);
p = double(stats.pValue); % Coefficient estimates
idx = p < alpha;

BNames = BNames(idx,:);
BNames.Estimate = B(idx);
BNames.p = p(idx);

T = glme.Variables;

% Convert both to String
T.Rat_ID = string(T.Rat_ID);
BNames.Level = string(BNames.Level);

[~,TID] = findgroups(T(:,{'Rat_ID','Treatment'}));
data = outerjoin(BNames,TID,'Type','left',...
   'LeftKeys',{'Level'},...
   'RightKeys',{'Rat_ID'},...
   'LeftVariables',{'Name','Estimate','p'},...
   'RightVariables',{'Rat_ID', 'Treatment'});
data = movevars(data,{'Rat_ID', 'Treatment'},'before',1);
[~,idx] = sort(data.Treatment,'ascend');
data = data(idx,:);
fprintf(1,'\n\t\t\t\t\t---------------------\n');
fprintf(1,'\t\t\t\t\t\t<strong>RANDOM EFFECTS</strong>');
fprintf(1,'\n\t\t\t\t\t---------------------\n');
disp(data);

end