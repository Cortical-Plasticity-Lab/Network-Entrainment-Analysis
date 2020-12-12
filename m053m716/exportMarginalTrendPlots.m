function [fig,T_marg] = exportMarginalTrendPlots(glme,epoch)
%EXPORTMARGINALTRENDPLOTS Export plots for longitudinal groupings by epoch using only marginal estimations for model fixed effects
%
%  fig = exportMarginalTrendPlots(glme,epoch);
%
% Inputs
%  glme  - Result from `fitglme` using data table
%  epoch - The experimental epoch ("Pre", "Stim", or "Post")
%
% Output
%  fig    - Figure handle
%  T_marg - Table with all same values as original except `MFR` is replaced
%           by the predicted output.
% 
% See also: Contents, mfr_stats_trends.m

fig = default.figure(sprintf('%s Trend Boxplots',epoch),...
   'Position',[0.1 0.1 0.8 0.8]);
T_marg = glme.Variables;
[G,TID] = findgroups(T_marg(:,{'Treatment','Epoch'}));
TID.nPulses = splitapply(@(x)round(nanmean(x)),T_marg.nPulses,G);
T_marg = 

T_marg.MFR = exp(predict(glme,glme.Variables,'Conditional',false));

[G,TID] = findgroups(T_marg(:,{'Treatment','Day','Epoch'}));
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
   idx = ismember(G,iSel) & ~T_marg.Exclude;
   mu(ii) = nanmean(T_marg.MFR(idx));
   sd(ii) = nanstd(T_marg.MFR(idx));
   data = T_marg.MFR(idx);
   dayList = T_marg.Day(idx);
   [dayList,iSort] = sort(dayList,'ascend');
   
   allDays = getDayLabels(dayList);
   data = data(iSort);
   
   boxplot(ax,data,allDays);
   title(ax,sprintf('%s: %s',groupings{ii,1},groupings{ii,2}),...
      'FontName','Arial','Color','k');
   ylabel(ax,'Daily MFR_{Marginal}','FontName','Arial','Color','k');
   set(ax,...
      'XTickLabelRotation',30,...
      'XTick',ax.XTick(1:2:end),...
      'LineWidth',1.5,...
      'FontName','Arial',...
      'FontSize',12,...
      'YLim',T_marg.Properties.UserData.MFR_THRESH,...
      'YTick',[0.1 1 10] ...
      );
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
ylabel(ax,'Overall Marginal MFR (spikes/sec)','FontName','Arial','Color','k');
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
tSub = T_marg(~T_marg.Exclude,:);
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
ylabel(ax,'MFR_{Marginal}','FontName','Arial','Color','k');
title(ax,sprintf('Epoch[%s] Daily Trends by Treatment',epoch),'FontName','Arial','Color','k','FontWeight','bold');

   function days_str = getDayLabels(days)
      days_str = strings(size(days));
      for iDay = 1:numel(days_str)
         days_str(iDay) = string(sprintf('Day-%02d',days(iDay)));
      end      
   end

end