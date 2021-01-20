function fig = exportTrendPlots(glme,epoch,response,groupings)
%EXPORTTRENDPLOTS Export plots for longitudinal groupings by epoch
%
%  fig = exportTrendPlots(glme,epoch);
%  fig = exportTrendPlots(glme,epoch,response,groupings);
%
% Inputs
%  T     - Data table
%  epoch - The experimental epoch ("Pre", "Stim", or "Post")
%
% Output
%  fig   - Figure handle
% 
% See also: Contents, mfr_stats_trends.m

if nargin < 3
   response = 'MFR';
end

T = glme.Variables;

fig = default.figure(sprintf('%s Trend Boxplots',epoch),...
   'Position',[0.1 0.1 0.8 0.8]);

[G,TID] = findgroups(T(:,{'Treatment','Day','Epoch'}));
if nargin < 4
   groupings = {'C',epoch; ...
                'RS',epoch;...
                'ADS',epoch};
end
names = {'Control (C)','Random (RS)','Activity-Dependent (ADS)'};
c = {'#846663';'#f10c0c';'#3e64fb'}; % Color codings
 
k = size(groupings,1);
Gc = cell(k,1);
for iG = 1:k
   Gc{iG} = unique(T.Treatment(string(T.Treatment)==string(groupings{iG,1})));
end


mu = nan(1,k);
sd = nan(1,k);

fullDaysNum = unique(sort(T.Day,'ascend'));
fullDaysList = getDayLabels(fullDaysNum);
% P = T(string(T.Epoch)==epoch,:);

nPredRows = numel(fullDaysNum);
epoch = unique(T.Epoch(string(T.Epoch)==epoch));
P = T(1:nPredRows,:);
P.Epoch = repmat(epoch,nPredRows,1);
P.Day = fullDaysNum;

for ii = 1:k
   ax = subplot(k,2,ii*2);
   iSel = find(TID.Treatment==string(groupings{ii,1}) & ...
               TID.Epoch==string(groupings{ii,2}));
   idx = ismember(G,iSel) & ~T.Exclude;
   mu(ii) = nanmean(T.(response)(idx));
   sd(ii) = nanstd(T.(response)(idx));
   data = T.(response)(idx);
   dayList = T.Day(idx);
   [dayList,iSort] = sort(dayList,'ascend');
   
   allDays = getDayLabels(dayList);
   uAllDays = unique(allDays);
   missingDays = setdiff(fullDaysList,uAllDays);   
   data = data(iSort);
   
   if ~isempty(missingDays)
      data = [data; nan(numel(missingDays),1)]; %#ok<AGROW>
      allDays = [allDays; missingDays]; %#ok<AGROW>
   end
   
   % Show the observed data using boxplots
   data = data(iSort);
   COL = validatecolor(c{ii});   
   boxplot(ax,data,allDays,'GroupOrder',fullDaysList,...
      'BoxStyle','filled','Colors',COL);
   
   % Get prediction table for this marginal grouping, so that we can
   % predict the Fixed-Effects-Only model output and superimpose as a trend
   % on the box plots that represent the actual data.
   P = predictorTable(P,Gc{ii});
   data_p = exp(predict(glme,P,'Conditional',false));
   default.line(ax,fullDaysNum-5,data_p,'Color',COL.*0.75); % Remove offset since fullDaysNum is in days but the ticks are aligned to indices technically
%    default.line(ax,P.Day-5,data_p,'Color',COL.*0.75); % Produce the same
%                                                       % result using full
%                                                       % dataset. This is
%                                                       because we set
%                                                       'Conditional' to
%                                                       false.
   title(ax,sprintf('%s: %s',groupings{ii,1},groupings{ii,2}),...
      'FontName','Arial','Color','k');
   ylabel(ax,sprintf('Daily %s',response),...
      'FontName','Arial','Color','k');
   if strcmp(response,'MFR')
      set(ax,...
         'XTickLabelRotation',30,...
         'XTick',1:2:numel(fullDaysList),...
         'XTickLabel',fullDaysList(1:2:end),...
         'LineWidth',1.5,...
         'FontName','Arial',...
         'FontSize',12,...
         'YLim',T.Properties.UserData.MFR_THRESH,...
         'YScale','log',...
         'YTick',[0.1 1 10] ...
         );
   else
      set(ax,...
         'XTickLabelRotation',30,...
         'XTick',1:2:numel(fullDaysList),...
         'XTickLabel',fullDaysList(1:2:end),...
         'LineWidth',1.5,...
         'FontName','Arial',...
         'FontSize',12,...
         'YScale','log',...
         'YTick',[0.1 1 10] ...
         );
   end
end
ax = subplot(k,2,1:2:(numel(groupings)-3));
set(ax,'XTick',1:k,...
   'XTickLabels',names,...
   'NextPlot','add',...
   'XTickLabelRotation',5,...
   'XColor','none',...
   'LineWidth',1.5,...
   'FontWeight','bold',...
   'FontName','Arial',...
   'FontSize',13,...
   'YLim',[0 15],...
   'XAxisLocation','top',...
   'YTick',[5 10]);

c = {'#846663';'#f10c0c';'#3e64fb'};
for ii = 1:k
   bar(ax,ii,mu(ii),'FaceColor',c{ii},'EdgeColor','k','LineWidth',1.25,...
      'DisplayName',string(names{ii}));
end
errorbar(ax,1:k,mu,sd./2,sd./2,'LineStyle','none','LineWidth',1.5,...
   'DisplayName','1 STD');
title(ax,sprintf('Epoch[%s] Grand Means by Treatment',epoch),...
   'FontName','Arial','Color','k');
if strcmp(response,'MFR')
   ylabel(ax,'Overall MFR (spikes/sec)','FontName','Arial','Color','k');
else
   ylabel(ax,response,'FontName','Arial','Color','k');
end
default.legend(ax);

ax = subplot(k,2,numel(groupings)-1);
set(ax,'XLim',[5 27],...
   'XTick',[7 14 21],...
   'XTickLabel',{'Day-07','Day-14','Day-21'},...
   'NextPlot','add',...
   'LineWidth',1.5,...
   'FontWeight','bold',...
   'FontSize',14,...
   'XColor','k',...
   'YColor','k',...
   'YLim',[-5 15],...
   'YTick',[-5  0  5  15],'FontName','Arial');
tSub = T(~T.Exclude,:);
[G,TID] = findgroups(tSub(:,{'Rat_ID','Day','Epoch'}));
[~,~,iURat] = unique(TID.Rat_ID);
TID.Rat_Index = iURat;
[uDay,~,iUDay] = unique(TID.Day);
TID.Day_Index = iUDay;
[~,~,iUEpoc] = unique(TID.Epoch);
TID.Epoch_Index = iUEpoc;

X = cell(3,21);
for ii = 1:numel(uDay)
   for ik = 1:k
      iSel = find(TID.Epoch==epoch & TID.Day_Index==ii);
      idx = ismember(G,iSel) & ismember(tSub.Treatment,string(groupings{ik,1}));
      X{ik,ii} = tSub.(response)(idx);
   end
end


for ii = 1:k
   gfx__.plotWithShadedError(ax,(6:26)',X(ii,:)',...
      'Smooth',true,'Tag',string(groupings{ii,1}),...
      'Color',c{ii},'FaceColor',c{ii},'FaceAlpha',0.25,'LineWidth',3);
end
% xlabel(ax,'Post-Op Day','FontName','Arial','Color','k');
ylabel(ax,response,'FontName','Arial','Color','k');
title(ax,sprintf('Epoch[%s] Daily Trends by Treatment',epoch),'FontName','Arial','Color','k','FontWeight','bold');

   function days_str = getDayLabels(days)
      days_str = strings(size(days));
      for iDay = 1:numel(days_str)
         days_str(iDay) = string(sprintf('Day-%02d',days(iDay)));
      end      
   end

   function P = predictorTable(P,group)
      P.Treatment = repmat(group,size(P,1),1);
   end

end