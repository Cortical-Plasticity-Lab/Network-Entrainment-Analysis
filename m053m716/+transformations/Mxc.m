function logMXC = Mxc(MXC)
%Mxc Returns log-transformed maximum I/O correlation values
%
%  logMXC = transformations.Mxc(MXC);
%
% Inputs
%  MXC     - Maximum I/O correlations
%  
% Output
%  logMXC  - Maximum I/O correlation values
%
% See also: Contents, importFRstats, importIOstats

logMXC = real(log(MXC));

end