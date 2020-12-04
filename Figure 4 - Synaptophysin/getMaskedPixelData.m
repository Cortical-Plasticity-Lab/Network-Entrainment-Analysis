function [data,meta] = getMaskedPixelData(F)
%% GETMASKEDPIXELDATA   Get pixels masked by ROIs of interest
%
%  [data,meta] = GETMASKEDPIXELDATA(F,idx);
%
%  --------
%   INPUTS
%  --------
%      F    :     File struct from DIR that points to image file.
%
%  --------
%   OUTPUT
%  --------
%     data  :     Pixel data from thresholded regins of image file
%
%     meta  :     Metadata associated with that image
%
% By: Max Murphy  v1.0  2019-04-18  Original version (R2017a)

%% CONSTANTS
ROIDIR = 'ROI';

%% USE RECURSION
n = numel(F);
if n > 1
   data = cell(n,1);
   meta = struct(...
       'Name',cell(n,1),...
       'Group',cell(n,1),...
       'Area',cell(n,1),...
       'Hemisphere',cell(n,1));
   for ii = 1:numel(F)
      [data{ii},meta(ii)] = getMaskedPixelData(F(ii));
   end
   return;
end


%% GET IMAGE AND METADATA

imfile = fullfile(F.folder,F.name);
[I,dim] = readJP2(imfile);
I = I.';

[~,fdata,~] = fileparts(imfile);
meta = extractMetadata(fdata);

%% GET ROI FOR DIFFERENT ROIS ON THIS IMAGE
roiDir= fullfile(F.folder,ROIDIR);

sROI = ReadImageJROI(fullfile(roiDir,[fdata '.roi']));
sRegion = ROIs2Regions({sROI},[dim(2) dim(1)]);
data = double(I(sRegion.PixelIdxList{1}));

idx = data <= 0;
data(idx) = [];

end