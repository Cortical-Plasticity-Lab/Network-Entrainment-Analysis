function contents = exportStats(glme,name,notes)
%EXPORTSTATS Function to compartmentalize scraping of Command Window output and generation of *.txt stats report
%
%  exportStats(glme,name);
%
% Inputs
%  glme  - Result from Matlab `fitglme`
%  name  -
%  notes - (Optional) notes string to tag at beginning of exported file
%
% Output
%  contents - Command Window text that is printed to the exported txt file
%
% See also: Contents, main.m, importFRstats, fitglme

strDate = string(date());

if nargin < 2
   name = string(sprintf('Reports/Unnamed_Stats_Export__%s.txt',strDate));
else
   name = string(name);
end

if ~contains(name,strDate)
   name = strrep(name,".txt",sprintf('__%s.txt',strDate));
end


[p,f,e] = fileparts(name);

if isempty(e) || e == ""
   e = ".txt";
end

if isempty(p) || p == ""
   p = "Reports";
end

if exist(p,'dir')==0
   mkdir(p);
end

name = fullfile(p,strcat(f,e));

if nargin < 3
   notes = "";
end

fprintf(1,'--- <strong>MODEL</strong> ---\n\n');
disp(glme);
disp('<strong>R-squared:</strong>');
disp(glme.Rsquared);
fprintf(1,'\n-- <strong>END MODEL</strong> --\n\n');
fprintf(1,'--- <strong>ANOVA</strong> ---\n');
disp(anova(glme));
fprintf(1,'\n-- <strong>END ANOVA</strong> --\n\n');
pause(2);

[~,contents,~] = command_window_text();
if exist(name,'file')~=0
    delete(name);
end

fid = fopen(name,'w');
fprintf(fid,'**GLME: %s**\n',string(date()));
if notes~=""
   fprintf(fid,'--- <strong>NOTES</strong> ---\n\n');
   fprintf(fid,'%s\n',notes);
   fprintf(fid,'-- <strong>END NOTES</strong> --\n\n');
end
fprintf(fid,'%s',contents); 
fclose(fid);

clc;
fprintf(1,'\n<strong>GLME stats report export complete.</strong>\n');
fprintf(1,'\t->\tContents in: %s\n\n',name);

end