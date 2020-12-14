function [SMFR,LMFR,omega] = MFR(MFR_raw,thresh)
%MFR Returns transformations on mean firing rate
%
%  [SMFR,LMFR,omega] = transformation.MFR(MFR_raw,thresh);
%
% Inputs
%  MFR_raw - Day with minimum value as 1, on linear scale
%  thresh  - Approximate maximum plausible FR (for omega only)
%  
% Output
%  SMFR  - Square-root-transformed MFR
%  LMFR  - Log-transformed MFR
%  omega - Scaled log-log transformed MFR
%
% See also: Contents, importFRstats, importIOstats

SMFR = sqrt(MFR_raw); % square-root transformed MFR
LMFR = log(MFR_raw); % log-transformed MFR
omega = MFR_raw./(4*thresh); % "normalized" spike frequency, assuming there is a fixed upper bound on spike "sampling frequency"

end