function [pVal,F,DF1,DF2] = reportCoefTest(glme,k,iZero)
%REPORTCOEFTEST Return result of coef test for different rows
%
%  [pVal,F,DF1,DF2] = reportCoefTest(glme,k);
%  [pVal,F,DF1,DF2] = reportCoefTest(glme,k,iZero);
%
% Inputs
%  glme - GeneralizedLinearMixedEffectsModel
%  k    - Observation rows to use for extracting design matrix parts.
%  iZero- Indices of coefficients to zero out. Default is 1:10
%
% Output
%  [pVal,F,DF1,DF2] - See GeneralizedLinearMixedEffectsModel.coefTest

if nargin < 3
   iZero = 1:10;
end

clc;
X = glme.designMatrix;
T = glme.Variables;
pVal = nan(size(k));
F = nan(size(k));
DF1 = nan(size(k));
DF2 = nan(size(k));

c = glme.CoefficientNames;
names = strings(size(c));
names(1) = "Int";
for ii = 2:numel(c)
   tmp = strsplit(c{ii},{'_',':'});
   names(ii) = string(strjoin(tmp(2:2:end),':'));
end

for ik = 1:numel(k)
%    design = [zeros(1,10),X(k(ik),11:end)];
   design = X(k(ik),:);
   design(iZero) = 0;
%    design = [0, X(k(ik),2:end)]; % Exclude intercept
   fprintf(1,'<strong>-- Row %d --</strong>\n',k(ik));
   fprintf(1,'<strong>T(%d,:):</strong>\n',k(ik));
   disp(T(k(ik),:));
   fprintf(1,'\n<strong>%15s</strong>','Term:');
   fprintf(1,'%12s',names);
   fprintf(1,'\n<strong>%15s</strong>',sprintf('X(%d,:):',k(ik)));
   fprintf(1,'%12d',design);
   [pVal(ik),F(ik),DF1(ik),DF2(ik)] = coefTest(glme,design,0); 
   fprintf(1,'\n\nP[F(%d, %d) > |f| | f = %6.4f] ~ %6.4f\n\n', ...
      DF1(ik),DF2(ik),F(ik),pVal(ik));
end

end