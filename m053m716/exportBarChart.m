function [fig,P1,P2] = exportBarChart(Y,varargin)
%EXPORTBARCHART Export bar chart for Figure 4 by-area comparisons
%
%   fig = exportBarChart(Y);
%   fig = exportBarChart(Y,'Name',value,...);
%   [fig,P1,P2] = ... 
%
% Inputs
%   Y        - Data table with all intensity values extracted in `data` included as cell array for each corresponding image. 
%   varargin - (Optional) 'Name',value pairs:
%                 -- Might change --
%                 * 'ErrorType' : 'STD' | 'SEM' | 'Image' | 'Rat' | 'Area'/'Site'/'Location' | 'Group'
%                    + 'STD' (def) - Compute standard deviation from data
%                                    as grouped for a given
%                                    Area:Hemisphere:Group combination.
%                                    Seems like the best choice.
%  
%                    + 'SEM' - Computes standard error from data as grouped
%                                for a given Area:Hemisphere:Group
%                                combination. Most likely underestimates
%                                the dispersion of that data. Not
%                                recommended.
%
%                    + 'Image' - Computes standard deviation of the mean
%                              values of each unique fluorescent intensity
%                              image. Note that for SHAM this goes to zero
%                              since each grouping only has one 
%        
%                    + 'Rat' - Computes standard deviation of the mean
%                              values for data grouped by rat.
%
%                    + 'Area' - Computes standard deviation of the mean
%                                values for data grouped by Area
%                                ("spatial groupings" so this is the same
%                                as 'Site' or 'Location').
%     
%                    + 'Group' - Computes standard deviation of the mean
%                                values for data grouped by 'ADS', 'SHAM'
%                                or 'RS'.
%
%                 -- Probably don't change --
%                 * 'Group' : ["SHAM"; "ADS"; "RS"]
%                 * 
%
% Output
%   fig - Figure handle
%   [P1,P2] - Return first and second properties tables also.
%
% See also: main.m

% First properties table
pars = struct;
pars.Group = ["SHAM"; "ADS"; "RS"];
pars.Color = [0 0 0; 0 0 1; 1 0 0];
pars.Offset = [-0.5; 0; 0.5];
% Second properties table
pars.ID = ["LH S1"; "LH RFA"; "RH S1"; "RH RFA"];
pars.XTick = [1;3;5;7];
% Other properties
pars.ErrorType = 'SDM'; % 'SD' or 'STD' | 'SEM' | 'SDM' | 'Grouped'

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
    'XTick',P2.XTick,'XLim',[0 8],'YLim',[0 45],'YTick',[0 15 30 45],...
    'XTickLabels',P2.ID);
ylabel(ax,sprintf('Mean Pixel Intensity\n(All Masked Pixels)'),...
    'FontName','Arial','Color','k','FontSize',16,'FontWeight','bold');

% Group data
Y.Name = string(Y.Name);
Y.Group = string(Y.Group);
Y.Area = string(Y.Area);
Y.Hemisphere = string(Y.Hemisphere);

Y.ID = strcat(Y.Hemisphere," ",Y.Area);
[G,TID] = findgroups(Y(:,{'ID','Group'}));
TID.Name = splitapply(@(x)x(1),Y.Name,G);
TID.Mean = splitapply(@(C)nanmean(vertcat(C{:})),Y.data,G);

switch upper(pars.ErrorType)
   case {'SD','STD','STANDARD DEVIATION'}
      TID.Error = splitapply(@(C)nanstd(vertcat(C{:}),[],1),Y.data,G);
      TID.Properties.VariableDescriptions{'Error'} = 'STD';
   case {'SEM','SE','STANDARD ERROR', 'STANDARD ERROR OF THE MEAN'}
      TID.Error = splitapply(@(C)nanstd(vertcat(C{:}),[],1)/sqrt(numel(vertcat(C{:}))),Y.data,G);
      TID.Properties.VariableDescriptions{'Error'} = 'SEM';
   case 'IMAGE'
      TID.Error = splitapply(@(C)nanstd(cellfun(@nanmean,C,'UniformOutput',true),[],1),Y.data,G);
      TID.Properties.VariableDescriptions{'Error'} = ...
         'STD (by Image)';
   case {'AREA','SITE','LOC','LOCATION','HEMISPHERE','SPATIAL','ID'}
      [G,tmp] = findgroups(Y(:,{'ID'}));
      tmp.Error = splitapply(@(C)nanstd(vertcat(C{:}),[],1),Y.data,G);
      TID = outerjoin(TID,tmp,'Keys',{'ID'},...
         'Type','Left',...
         'LeftVariables',{'ID','Group','Mean'},...
         'RightVariables',{'Error'});
      TID.Properties.VariableDescriptions{'Error'} = ...
         'STD (by Location)';
   case {'RAT','NAME','ANIMAL'}
      [G,tmp] = findgroups(Y(:,{'Name'}));
      tmp.Group = splitapply(@(x)x(1),Y.Group,G);
      tmp.Mean = splitapply(@(C)nanmean(vertcat(C{:}),1),Y.data,G);
      TID.Error = nan(size(TID,1),1);
      for ii = 1:numel(pars.Group)
         x = tmp.Mean(tmp.Group==pars.Group(ii));
         if numel(x) > 1
            TID.Error(TID.Group==pars.Group(ii)) = nanstd(x,[],1);
         end
      end
      TID.Properties.VariableDescriptions{'Error'} = ...
         'STD (by Rat)';
   case {'GROUP','TREATMENT'}
      [G,tmp] = findgroups(Y(:,{'Group'}));
      tmp.Error = splitapply(@(C)nanstd(vertcat(C{:}),[],1),Y.data,G);
      TID = outerjoin(TID,tmp,'Keys',{'Group'},...
         'Type','Left',...
         'LeftVariables',{'ID','Group','Mean'},...
         'RightVariables',{'Error'});
      TID.Properties.VariableDescriptions{'Error'} = ...
         'STD (by Treatment)';
   otherwise
      error('Unrecognized value of `ErrorType`: %s',pars.ErrorType);
end

for ii = 1:size(P1,1)
    t = TID(TID.Group==P1.Group(ii),:);
    t = outerjoin(t,P2,'Type','left',...
        'LeftVariables',{'ID','Group','Mean','Error'},...
        'RightVariables',{'XTick'},...
        'Keys',{'ID'});
    t.X = t.XTick + P1.Offset(ii);
    bar(ax,t.X,t.Mean,...
        'EdgeColor','none',...
        'FaceColor',P1.Color(ii,:),...
        'DisplayName',P1.Group(ii),...
        'Tag',P1.Group(ii),'BarWidth',0.20);
    h = errorbar(t.X,t.Mean,-t.Error*0.5,t.Error*0.5,...
        'Parent',ax,...
        'LineWidth',1.5,'Color','m','LineStyle','none',...
        'DisplayName',sprintf('1 %s',TID.Properties.VariableDescriptions{'Error'}));
    h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end
h.Annotation.LegendInformation.IconDisplayStyle = 'on';
legend(ax,'FontName','Arial','TextColor','black','EdgeColor','none',...
    'FontSize',13,'FontWeight','bold');
end