function [fig,T_marg] = exportMarginalTrendPlots(glme,epoch)
%EXPORTMARGINALTRENDPLOTS Export plots for longitudinal groupings by epoch using marginal estimations for model fixed effects with simulated # stim pulses for random effects
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

[G,TID] = findgroups(T_marg(:,{'Treatment','Day','Epoch'}));
TID.logPulses_Mean = splitapply(@(x)round(nanmean(x)),T_marg.logPulses,G);
TID.logPulses_SD = splitapply(@(x)nanstd(x),T_marg.logPulses,G);
TID.logPulses_Mean(TID.Epoch~="Stim") = 0;
TID.logPulses_SD(TID.Epoch~="Stim") = 0;
T_marg = outerjoin(T_marg,TID,...
   'Type','left',...
   'Keys',{'Treatment','Day','Epoch'},...
   'LeftVariables',T_marg.Properties.VariableNames,...
   'RightVariables',{'logPulses_Mean','logPulses_SD'});
T_marg.logPulses = T_marg.logPulses_Mean + randn(size(T_marg,1),1).*T_marg.logPulses_SD;
T_marg.MFR = exp(predict(glme,glme.Variables,'Conditional',true));
T_marg.MFR_mrg = exp(predict(glme,glme.Variables,'Conditional',false));

% labels = strcat(string(TID.Treatment),":D-", ...
%             num2str(TID.Day,'%02d'),"_{",...
%             string(TID.Epoch),"}");
groupings = {'C',epoch; ...
             'RS',epoch;...
             'ADS',epoch};
names = {'Control (C)','Random (RS)','Activity-Dependent (ADS)'};
c = {'#846663';'#f10c0c';'#3e64fb'}; % Color codings

k = size(groupings,1);
mu = nan(1,k);
sd = nan(1,k);
mu2 = nan(size(mu));
fullDaysList = unique(getDayLabels(sort(T_marg.Day,'ascend')));
for ii = 1:k
   ax = subplot(k,2,ii*2);
   iSel = find(TID.Treatment==string(groupings{ii,1}) & ...
               TID.Epoch==string(groupings{ii,2}));
   idx = ismember(G,iSel) & ~T_marg.Exclude;
   mu(ii) = nanmean(T_marg.MFR(idx));
   sd(ii) = nanstd(T_marg.MFR(idx));
   mu2(ii) = nanmean(T_marg.MFR_mrg(idx));
   data = T_marg.MFR(idx);
   dayList = T_marg.Day(idx);
   [dayList,iSort] = sort(dayList,'ascend');
   
   allDays = getDayLabels(dayList);
   uAllDays = unique(allDays);
   missingDays = setdiff(fullDaysList,uAllDays);   
   data = data(iSort);
   
   if ~isempty(missingDays)
      data = [data; nan(numel(missingDays),1)]; %#ok<AGROW>
      allDays = [allDays; missingDays]; %#ok<AGROW>
   end
   COL = validatecolor(c{ii});
   boxplot(ax,data,allDays,'GroupOrder',fullDaysList,'BoxStyle','filled','Colors',COL);
   title(ax,sprintf('%s: %s',groupings{ii,1},groupings{ii,2}),...
      'FontName','Arial','Color','k');
   ylabel(ax,'Daily MFR_{Marginal}','FontName','Arial','Color','k');
   set(ax,...
      'XTickLabelRotation',30,...
      'XTick',1:2:numel(fullDaysList),...
      'XTickLabels',fullDaysList(1:2:end),...
      'LineWidth',1.5,...
      'FontName','Arial',...
      'FontSize',12,...
      'YLim',T_marg.Properties.UserData.MFR_THRESH,...
      'YScale','log',...
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
   'YLim',[0 7],...
   'XAxisLocation','top');


for ii = 1:k
   bar(ax,ii,mu(ii),'FaceColor',c{ii},'EdgeColor','k',...
      'LineWidth',1.25,...
      'DisplayName',string(names{ii}),...
      'FaceAlpha',0.5,'EdgeAlpha',0.75);
   hbar = bar(ax,ii,mu2(ii),...
      'FaceColor',c{ii},'EdgeColor','none',...
      'DisplayName',sprintf('Marginal Mean: %s',string(names{ii})),...
      'FaceAlpha',0.5);
   hbar.Annotation.LegendInformation.IconDisplayStyle = 'off';
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
   'YLim',[-5 10],...
   'FontName','Arial');
tSub = T_marg(~T_marg.Exclude,:);
[G,TID] = findgroups(tSub(:,{'Rat_ID','Day','Epoch'}));
[~,~,iURat] = unique(TID.Rat_ID);
TID.Rat_Index = iURat;
[uDay,~,iUDay] = unique(TID.Day);
TID.Day_Index = iUDay;
[~,~,iUEpoc] = unique(TID.Epoch);
TID.Epoch_Index = iUEpoc;

Z = glme.designMatrix;
iTerms = 15:18;
ALPHA = 0.01;
X = cell(3,21);
T_marg.Properties.UserData.posthoc = struct(...
   'p',cell(21,1),'F',cell(21,1),'DF1',cell(21,1),'DF2',cell(21,1));
tmp = struct('p',{},'F',{},'DF1',{},'DF2',{});
hTest = zeros(1,21);

for ii = 1:numel(uDay)
   iADS = find(T_marg.Treatment=="ADS" & T_marg.Day==uDay(ii) & string(T_marg.Epoch)==string(epoch),1,'first');
   iRS = find(T_marg.Treatment=="RS" & T_marg.Day==uDay(ii) & string(T_marg.Epoch)==string(epoch),1,'first');
   H = zeros(1,18);
   H(iTerms) = Z(iADS,iTerms) - Z(iRS,iTerms);
   if any(isnan(H))
      tmp(1).p = nan;
      tmp(1).F = nan;
      tmp(1).DF1 = nan;
      tmp(1).DF2 = nan;
   else
      [tmp(1).p,tmp(1).F,tmp(1).DF1,tmp(1).DF2] = coefTest(glme,H,0);
      hTest(ii) = (tmp(1).p <= ALPHA);
   end
   T_marg.Properties.UserData.posthoc(ii) = tmp;
   
   for ik = 1:k
      iSel = find(TID.Epoch==epoch & TID.Day_Index==ii);
      idx = ismember(G,iSel) & ismember(tSub.Treatment,string(groupings{ik,1}));
      X{ik,ii} = tSub.MFR(idx);
   end
end
T_marg.Properties.UserData.hTest.(epoch).result = hTest;
T_marg.Properties.UserData.hTest.(epoch).note = sprintf('Compares ADS to RS by day for %s epoch.',epoch);

for ii = 1:k
   gfx__.plotWithShadedError(ax,(6:26)',X(ii,:)',...
      'Smooth',true,'Tag',string(groupings{ii,1}),...
      'Color',c{ii},'FaceColor',c{ii},'FaceAlpha',0.25,'LineWidth',3);
end
dayVec = 6:26; % Post-Op Days
iTest = find(hTest);
line(ax,dayVec,hTest.*7.5,...
   'LineStyle','none','LineWidth',1,'Marker','*',...
   'Color','k',...
   'MarkerIndices',iTest,...
   'Tag','Post-Hoc Significance Test',...
   'DisplayName','\alpha = 0.01 Difference between ADS and RS');
for ii = 1:numel(iTest)
   text(ax,dayVec(iTest(ii)),8,sprintf('%d',dayVec(iTest(ii))),...
      'FontName','Arial','Color','k','FontSize',12,...
      'VerticalAlignment','bottom',...
      'HorizontalAlignment','center');
end

% xlabel(ax,'Post-Op Day','FontName','Arial','Color','k');
ylabel(ax,'MFR_{Marginal}','FontName','Arial','Color','k');
title(ax,sprintf('Epoch[%s] Daily Trends by Treatment',epoch),'FontName','Arial','Color','k','FontWeight','bold');
legend(ax,'FontName','Arial','TextColor','k','Location','south');
   function days_str = getDayLabels(days)
      days_str = strings(size(days));
      for iDay = 1:numel(days_str)
         days_str(iDay) = string(sprintf('Day-%02d',days(iDay)));
      end
   end

end