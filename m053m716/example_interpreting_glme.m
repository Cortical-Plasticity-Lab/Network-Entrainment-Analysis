clc;

% (Run after running `main.m`)
% Get the test value for the desired coefficient:
k = [1, 83595, 16832];
reportCoefTest(glme,k);


% For Coefficient estimates, process for estimating significance:

sig = @(t,df)(1 - tcdf(t,df) + tcdf(-t,df)); % 2-sided t-test
result = @(t,df,p)fprintf(1,'\nP[|t| > %6.4f|df = %d) ~ %6.4f\n',t,df,p);

% For example, we have the following values of t and df for the
% Synaptophysin GLME coefficient 'Group_ADS:Hemisphere_LH:Area_RFA'
t = 2.74462511308895;
df = 219987;
p = sig(t,df);
result(t,df,p);

% Do we really believe that there are 219,987 independent degrees of
% freedom from our experiment? What if we use 20 recordings * 10 animals =
% 200 degrees of freedom.
df = 200;
p = sig(t,df);
result(t,df,p);

% Technically, the coefficient 'Group:Hemisphere:Area' has 3 levels of
% group, 2 levels of hemisphere, and 2 levels of area. Since degrees of
% freedom is one less than the total number, we should compute 
%     df = 3 * 2 * 2 - 1 = 11
df = 11;
p = sig(t,df);
result(t,df,p);

% Is it reasonable to assume that there are slightly more degrees of
% freedom available due to the nature of time-series data? Maybe. If we add
% in random unaccounted for degrees of freedom in two independent levels,
% we would multiply df by a factor of 4 and subtract 1, leaving us with df
% = 47.
df = 47;
p = sig(t,df);
result(t,df,p);