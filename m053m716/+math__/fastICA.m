function [Zica, W, T, mu] = fastICA(Z,r,varargin)
%FASTICA Use Fast ICA algorithm to do independent components analysis
%
%	This version is adapted from the original function, which was
%   provided by Brian Moore (brimoor@umich.edu)
%
% Syntax:       Zica = math__.fastICA(Z,r);
%               Zica = math__.fastICA(Z,r,p);
%               Zica = math__.fastICA(__,'name',value,...);
%               [Zica, W, T, mu] = math__.fastICA(Z,r);
%
% Inputs:       Z is an d x n matrix containing n samples of d-dimensional
%               data
%
%               r is the number of independent components to compute
%
%				p can be provided as a defaults (see "Defaults" in code below)
%				-> Otherwise, can set the parameters using 'name',value syntax
%
%               [OPTIONAL] varargin == 'name', value pairs.
%
%               [OPTIONAL] 'p.type' = {'kurtosis','negentropy'} specifies
%               which flavor of non-Gaussianity to maximize. The default
%               value is p.type = 'kurtosis'
%
%               [OPTIONAL] 'p.verbose' determines what status updates to print
%               to the command window. The choices are
%
%                       p.verbose = 0: no printing
%                       p.verbose = 1: print iteration status
%
% Outputs:      Zica is an r x n matrix containing the r independent
%                    components - scaled to unit variance - corresponding
%                    to the input sample data `Z`
%
%               W
%
%               T is the whitening tran
%
%               mu is the d x 1 sample mean of Z
%
%               W and T are the ICA transformation matrices such that
%                 ```
%                    Zr = T \ W' * Zica + repmat(mu,1,n);
%
%                       or
%
%                    Zr' = Zica' * W / T' + repmat(mu',n,1);
%                 ```
%               is the r-dimensional ICA approximation of Z [d x n]
%
% Description:  Performs independent component analysis (ICA) on the input
%               data using the Fast ICA algorithm
%
% Reference:    Hyvärinen, Aapo, and Erkki Oja. "Independent component
%               analysis: algorithms and applications." Neural networks
%               13.4 (2000): 411-430
%
% Author:       Brian Moore
%               brimoor@umich.edu
%
% Date:         April 26, 2015
%               November 12, 2016
%

% % Default parameters % %
p = struct;
p.min_learning_rate = 1e-10; 	% Minimum change in delta
p.min_tol = 1e-6;      			% Minimum criteria for convergence
p.tol = 1e-9;          			% Convergence criteria
p.max_iters = 250;     			% Max # iterations
p.verbose = 1;         			% 1 = show text, 0 = no info in commandline
p.type = 'negentropy'; 			% Metric to be minimized for ICA
p.whiten = true;       			% Whiten data (remove correlations)
p.center = true;       			% Center data (0 mean)
p.total_iters = 20000; 			% Total possible iterations

% % parse input % %
if nargin > 2
   if isstruct(varargin{1})
      p = varargin{1};
      varargin(1) = [];
   end
   
   for iV = 1:2:numel(varargin)
      p.(lower(varargin{iV})) = varargin{iV+1};
   end
end
p.type = lower(p.type);

% % mean-subtract and/or decorrelate data % %
if p.center
   [Zc, mu] = math__.centerRows(Z);
else
   Zc = Z;
   mu = mean(Z,2);
end

if p.whiten
   [Zcw, T] = math__.whitenRows(Zc);
else
   Zcw = Zc;
   T = eye(size(Zc,1));
end

% % NORMALIZE ROWS TO UNIT NORM % %
Z0 = @(X) bsxfun(@rdivide,X,sqrt(sum(X.^2,2)));

% % PERFORM FAST ICA ALGORITHM % %
if p.verbose
   % Prepare status updates
   fmt = sprintf('%%0%dd',ceil(log10(p.max_iters + 1)));
   str = sprintf('Iter %s: max(1 - |<w%s, w%s>|) = %%.4g\\n',fmt,fmt,fmt);
   fprintf(1,'<strong>***** Fast ICA (%s) *****</strong>\n',p.type);
end
W = Z0(rand(r,size(Z,1))); % Random initial weights
k = 0;
delta = inf;
learning = inf;
iter = p.max_iters;
while delta > p.min_tol && learning > p.min_learning_rate
   while delta > p.tol && k < iter
      k = k + 1;
      
      % Update weights
      deltalast = delta;   % Save last delta
      Wlast = W; 			% Save last weights
      Sk = permute(W * Zcw,[1, 3, 2]);
      switch p.type
         case 'kurtosis'
            G = 4 * Sk.^3;
            Gp = 12 * Sk.^2;
         case 'negentropy'
            G = Sk .* exp(-0.5 * Sk.^2);
            Gp = (1 - Sk.^2) .* exp(-0.5 * Sk.^2);
         otherwise
            error(['MATH__:' mfilename ':BadType'],...
               ['\n\t->\t<strong>[MATH__.FASTICA]:</strong> ' ...
               'Unsupported p.type: %s\n'], p.type);
      end
      W = mean(bsxfun(@times,G,permute(Zcw,[3, 1, 2])),3) - ...
         bsxfun(@times,mean(Gp,3),W);
      W = Z0(W);
      
      % Decorrelate weights
      [U, S, ~] = svd(W,'econ');
      W = U * diag(1 ./ diag(S)) * U' * W;
      
      % Update convergence criteria
      delta = max(1 - abs(dot(W,Wlast,2)));
      if p.verbose
         fprintf(str,k,k,k - 1,delta);
      end
      learning = abs(deltalast - delta);
   end
   iter = iter + p.max_iters;
   if iter > p.total_iters
      break;
   end
end
if p.verbose
   fprintf(1,'\n');
end

% % Apply ICA projection to centered/whitened data % %
Zica = W * Zcw;
end