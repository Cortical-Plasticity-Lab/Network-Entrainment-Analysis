function [fig,TID] = exportSwarmChart(Y,varargin)
%EXPORTSWARMCHART Export swarm chart for Figure 4 by-area comparisons
%
%   fig = exportSwarmChart(Y);
%   fig = exportSwarmChart(Y,'Name',value,...);
%   [fig,TID] = ... 
%
% Inputs
%   Y        - Data table with all intensity values extracted in `data` included as cell array for each corresponding image. 
%   varargin - (Optional) 'Name',value pairs:
%
% Output
%   fig - Figure handle
%   TID - Grouped data table with kernel density estimate
%
% See also: main.m

% First properties table
pars = struct;
pars.Bandwidth = 3;
pars.Kernel = 'epanechnikov'; % see: doc ksdensity

pars.Group = ["SHAM"; "ADS"; "RS"];
pars.Color = [0 0 0; 0 0 1; 1 0 0];
pars.Offset = [-0.8; 0; 0.8];
pars.NSample = 250;
% Second properties table
pars.ID = ["LH S1"; "LH RFA"; "RH S1"; "RH RFA"];
pars.XTick = [2;6;10;14];

fn = fieldnames(pars);
for iV = 1:2:numel(varargin)
   idx = strcmpi(fn,varargin{iV});
   if sum(idx)==1
      pars.(fn{idx}) = varargin{iV+1};
   end
end


P1 = table(pars.Group,pars.Color,pars.Offset);
P2 = table(pars.ID,pars.XTick);
P1.Properties.VariableNames = {'Group','Color','Offset'};
P2.Properties.VariableNames = {'ID','XTick'};

fig = figure(...
    'Name','Average pixel intensity By Area',...
    'Color','w',...
    'PaperOrientation','portrait',...
    'Units','Normalized',...
    'PaperUnits','inches',...
    'PaperSize',[8.5 11],...
    'Position',[0.3 0.085 0.3 0.6]);

ax = axes(fig,'XColor','k','YColor','k','NextPlot','add',...
    'LineWidth',1.5,'FontName','Arial','FontSize',16,...
    'XTick',P2.XTick,'XLim',[0 16],...
    'YLim',[0 105],'YTick',0:15:105,...
    'XTickLabels',P2.ID);
ylabel(ax,sprintf('Pixel Intensities\n(%d random values)',pars.NSample),...
    'FontName','Arial','Color','k','FontSize',16,'FontWeight','bold');

% Group data
Y.Name = string(Y.Name);
Y.Group = string(Y.Group);
Y.Area = string(Y.Area);
Y.Hemisphere = string(Y.Hemisphere);

Y.ID = strcat(Y.Hemisphere," ",Y.Area);
[G,TID] = findgroups(Y(:,{'ID','Group'}));
TID.Name = splitapply(@(x)x(1),Y.Name,G);
TID.Data = splitapply(@(C){vertcat(C{:})},Y.data,G);
TID.N = cellfun(@numel,TID.Data,'UniformOutput',true);
fprintf(1,'Computing kernel density estimates (Kernel: %s | Bandwidth: %3.2f)...',pars.Kernel,pars.Bandwidth); tic;
[TID.f,TID.yi] = cellfun(@(x)ksdensity(x,'Kernel',pars.Kernel,'Bandwidth',pars.Bandwidth),...
   TID.Data,'UniformOutput',false);
TID.f = cellfun(@(f)scaleSmoothFreqs(f),TID.f,'UniformOutput',false);
TID.yi = cellfun(@(y)[y(:); flipud(y(:))],TID.yi,'UniformOutput',false);
TID.NVert = cellfun(@numel,TID.f,'UniformOutput',true);
fprintf(1,'complete (%5.2f sec)\n',toc);

for ii = 1:size(P1,1)
    t = TID(TID.Group==P1.Group(ii),:);
    t = outerjoin(t,P2,'Type','left',...
        'LeftVariables',{'ID','Group','f','yi','NVert','Data','N'},...
        'RightVariables',{'XTick'},...
        'Keys',{'ID'});
    t.X = t.XTick + P1.Offset(ii);
    
    % Add smoothed estimate (violin shape)

    t.Faces = cell(size(t,1),1);
    t.Vertices = cell(size(t,1),1);
    for ik = 1:size(t,1)
       faces = [1:TID.NVert(ik), 1];
       verts = [t.f{ik}(:) + t.X(ik), t.yi{ik}(:)]; 
       h = patch(ax,'Faces',faces,'Vertices',verts,...
          'EdgeColor','none',...
          'FaceColor',P1.Color(ii,:),...
          'FaceAlpha',0.5,...
          'DisplayName',P1.Group(ii),...
          'Tag',sprintf('Violin - %s',P1.Group(ii)));
       h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    end
    
    % Add samples
    xAll = arrayfun(@(x,N){repelem(x,N,1)},t.X,t.N);
    xAll = vertcat(xAll{:});
    yAll = vertcat(t.Data{:});
    if pars.NSample < numel(yAll)
       iSelect = randsample(numel(yAll),pars.NSample,false);
       yy = yAll(iSelect);
       xx = xAll(iSelect);
    else
       xx = xAll;
       yy = yAll;
    end
    scatter(ax,xx+randn(size(xx)).*0.015,yy,...
       'Marker','o',...
       'MarkerFaceAlpha',0.5,...
       'MarkerEdgeColor','none',...
       'MarkerFaceColor',P1.Color(ii,:),...
       'SizeData',7,...
       'DisplayName',P1.Group(ii),...
       'Tag',P1.Group(ii));
end
legend(ax,'FontName','Arial','TextColor','black','EdgeColor','none',...
    'FontSize',13,'FontWeight','bold');
 
   function F = scaleSmoothFreqs(f)
      if max(f) > 0.4
         k = max(f)*2.5;
      else
         k = 1;
      end
      F = ([f(:); -flipud(f(:))])./k;
   end
end