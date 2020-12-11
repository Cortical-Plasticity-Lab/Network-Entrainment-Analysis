function fig = exportTrendPlots(T,epoch)
%EXPORTTRENDPLOTS Export plots for longitudinal groupings by epoch
%
%  fig = exportTrendPlots(T,epoch);
%
% Inputs
%  T     - Data table
%  epoch - The experimental epoch ("Pre", "Stim", or "Post")
%
% Output
%  fig   - Figure handle
% 
% See also: Contents, mfr_stats_trends.m

fig = default.figure(sprintf('%s Trend Boxplots',epoch),...
   'Position',[0.1 0.1 0.8 0.8]);

[G,TID] = findgroups(T(:,{'Treatment','Day','Epoch'}));
labels = strcat(string(TID.Treatment),":D-", ...
            num2str(TID.Day,'%02d'),"_{",...
            string(TID.Epoch),"}");
groupings = {'C',epoch; ...
             'RS',epoch;...
             'ADS',epoch};
names = {'Control (C)','Random (RS)','Activity-Dependent (ADS)'};
          
k = size(groupings,1);
mu = nan(1,k);
sd = nan(1,k);

for ii = 1:k
   ax = subplot(k,2,ii*2);
   iSel = find(TID.Treatment==string(groupings{ii,1}) & ...
               TID.Epoch==string(groupings{ii,2}));
   idx = ismember(G,iSel) & ~T.Exclude;
   mu(ii) = nanmean(T.MFR(idx));
   sd(ii) = nanstd(T.MFR(idx));
   data = T.MFR(idx);
   dayList = T.Day(idx);
   [dayList,iSort] = sort(dayList,'ascend');
   
   allDays = getDayLabels(dayList);
   data = data(iSort);
   
   boxplot(ax,data,allDays);
   title(ax,sprintf('%s: %s',groupings{ii,1},groupings{ii,2}),...
      'FontName','Arial','Color','k');
   ylabel(ax,'Daily MFR','FontName','Arial','Color','k');
   set(ax,'XTickLabelRotation',30,'YTick',[15 30 45],...
      'LineWidth',1.5,'FontName','Arial','FontSize',12,'YLim',[0 50],...
      'XTick',ax.XTick(1:2:end));
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
   'YLim',[0 10],...
   'XAxisLocation','top',...
   'YTick',[4 8]);

c = {'#846663';'#f10c0c';'#3e64fb'};
for ii = 1:k
   bar(ax,ii,mu(ii),'FaceColor',c{ii},'EdgeColor','k','LineWidth',1.25,...
      'DisplayName',string(names{ii}));
end
errorbar(ax,1:k,mu,sd./2,sd./2,'LineStyle','none','LineWidth',1.5,...
   'DisplayName','1 STD');
title(ax,sprintf('Epoch[%s] Grand Means by Treatment',epoch),...
   'FontName','Arial','Color','k');
ylabel(ax,'Overall MFR (spikes/sec)','FontName','Arial','Color','k');
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
      X{ik,ii} = tSub.MFR(idx);
   end
end


for ii = 1:k
   gfx__.plotWithShadedError(ax,(6:26)',X(ii,:)',...
      'Smooth',true,'Tag',string(groupings{ii,1}),...
      'Color',c{ii},'FaceColor',c{ii},'FaceAlpha',0.25,'LineWidth',3);
end
% xlabel(ax,'Post-Op Day','FontName','Arial','Color','k');
ylabel(ax,'MFR','FontName','Arial','Color','k');
title(ax,sprintf('Epoch[%s] Daily Trends by Treatment',epoch),'FontName','Arial','Color','k','FontWeight','bold');

   function days_str = getDayLabels(days)
      days_str = strings(size(days));
      for iDay = 1:numel(days_str)
         days_str(iDay) = string(sprintf('Day-%02d',days(iDay)));
      end      
   end

end