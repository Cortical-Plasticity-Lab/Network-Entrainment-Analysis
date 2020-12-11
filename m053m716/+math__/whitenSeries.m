function [Z,T] = whitenSeries(X,nSamples,nOverlap)
%WHITENSERIES  Whiten a zero-mean time-series vector, Z, over nSamples
%
%  Z = math__.whitenSeries(X,nSamples);
%  [Z,T] = math__.whitenSeries(X,nSamples);
%  [Z,T] = math__.whitenSeries(X,nSamples,nOverlap);
%
%  -- inputs --
%  X  :     A times-series process of interest to be whitened.
%           --> If it's a matrix, then samples are columns and rows are
%               elements of the multivariate process that were observed
%               simultaneously.
%  nSamples : (optional) # of samples for window to assume stationarity 
%  nOverlap : (optional) # of samples to overlap
%
%  -- output --
%  Z  :     Whitened version of X time-series
%  T  :     Whitening transformation matrix


if nargin < 2
   nSamples = round(0.1 * size(X,2)); % Split into tenths
   nSamples = max(nSamples,size(X,2)/nSamples); % Must be greater than # rows
end

if nargin < 3
%    % Use `nSamples-1` overlap
%    nOverlap = nSamples-1;
   nOverlap = 0;
end

if size(X,1) > 1
   Z = zeros(size(X));
   for i = 1:size(X,1)
      Z(i,:) = math__.whitenSeries(X(i,:),nSamples,nOverlap);
   end
   return;
end

nTotal = size(X,2);

y = fillmissing(X,'linear',2,'EndValues',0);

% Y = math__.chunkVector2Matrix(y,nSamples,nSamples-1);
[Y,vec] = math__.chunkVector2Matrix(y,nSamples,nOverlap);
Yt = Y.';

% Whiten data
% 1) Get whitening transform for "long-term" stationarity
% Get covariance of "chunked" data
R = cov(Yt');
% Use covariance to estimate whitening transform of ergodic signal
[U, S, ~] = svd(R);
T  = U * diag(1 ./ sqrt(diag(S))) * U';
Y_w = T * Yt;
% 2) Transform each window for "short-term" stationarity using "inverted"
%    windows.
% Y_w = math__.whitenRows(Y.').';

% Get "overlapped" averages in order to return to original vector form
Z = zeros(1,nTotal);
for i = 1:nTotal
   yThis = Y_w(vec == i);
   Z(1,i) = nanmean(yThis(:));
end

end