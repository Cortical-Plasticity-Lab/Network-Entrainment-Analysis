function TT = data2timetable(T)
%DATA2TIMETABLE Convert data so that each row is a unique day
%
%  TT = data2timetable(T);
%
% Inputs
%  T - Data table (see importIOstats)
%
% Output
%  TT - Time table, where each row is a unique day
%
% See also: Contents

T.Day = days(T.Day);

[~,tt] = findgroups(T(:,{'Day'}));

[G,TID] = findgroups(T(:,{'Rat_ID','Treatment','Day'}));
TID.Mxc = splitapply(@nanmean,T.Mxc,G);

n = size(tt,1);
[Rat_ID,iu] = unique(TID.Rat_ID);
Treatment = TID.Treatment(iu);

Key = table(Rat_ID,Treatment);
Key.VariableName = cell(size(Key,1),1);

for ii = 1:numel(Rat_ID)
   Key.VariableName{ii} = sprintf('Mxc_%s',strrep(string(Rat_ID(ii)),"-",""));
   tt.(Key.VariableName{ii}) = nan(n,1);
   tid = TID(TID.Rat_ID == Rat_ID(ii),:);
   for ik = 1:size(tid,1)
      tt.(Key.VariableName{ii})(tt.Day == tid.Day(ik)) = tid.Mxc(ik);
   end   
end

TT = table2timetable(tt,'RowTimes','Day');
TT.Properties.UserData.Key = Key;
end