function logPulses = Stimulus_Count(nPulses)
%STIMULUS_COUNT Returns log-transformed number of pulses with inf values set to zero
%
%  logPulses = transformations.Stimulus_Count(nPulses);
%
% Inputs
%  nPulses     - Number of stimulus pulses (counts)
%  
% Output
%  logPulses   - Log-transformed stimulus pulses, with inf values set to
%                 zero.
%
% See also: Contents, importFRstats, importIOstats

logPulses = log(nPulses);
logPulses(isinf(logPulses)) = 0; % So that it doesn't mess up the optimizer

end