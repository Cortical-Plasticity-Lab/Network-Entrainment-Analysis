function [out, raw, h]=command_window_text(varargin)
%COMMAND_WINDOW_TEXT Function for returning the text in the command window
%
% [out, raw, h] = command_window_text(varargin)
%
% Formatted into a cell, per line of output (preceding >> can be removed).
% Also outputs raw string, and the handle to the object if desired.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage: [out, raw, h]=command_window_text(strip_angle_brackets)
%
% Inputs:
% strip_angle_brackets: can be left out. If nonzero, strips the '>> ' from the start of lines
%
% Outputs:
% out: the text in the command window parsed to lines (blank lines removed) 
% raw: the raw string taken from the window
% h: container for handle; handle(1) is the handle we need (should only be one unless something weird is going on)
%
% Requires findjobj.m, available at:
% http://www.mathworks.com/matlabcentral/fileexchange/14317-findjobj-find-java-handles-of-matlab-graphic-objects
%
% Courtesy of Hugh Nolan:
%       Hugh Nolan (2020). Command window text (https://www.mathworks.com/matlabcentral/fileexchange/31438-command-window-text), 
%       MATLAB Central File Exchange. Retrieved December 4, 2020. 

[cmdWin]=com.mathworks.mde.cmdwin.CmdWin.getInstance;
cmdWin_comps=get(cmdWin,'Components');
subcomps=get(cmdWin_comps(1),'Components');
h=get(subcomps(1),'Components');
raw=get(h(1),'text');
out=textscan(raw,'%s','Delimiter','\r\n','MultipleDelimsAsOne',1);
out=out{1};
if nargin==1 && varargin{1}~=0 || nargin==0
    typed_commands=strncmp('>> ',out,3);
    out(typed_commands)=cellfun(@(t) t(4:end),out(typed_commands),'UniformOutput',0);
end
end