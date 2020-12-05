function [data,meta] = getMaskedPixelData(F,thresh)
%GETMASKEDPIXELDATA   Get pixels masked by ROIs of interest
%
%  [data,meta] = GETMASKEDPIXELDATA(F,thresh);
%
%  --------
%   INPUTS
%  --------
%      F      :     File struct from DIR that points to image file.
%      thresh :     Intensity thresholds for exclusion
%
%  --------
%   OUTPUT
%  --------
%     data  :     Pixel data from thresholded regins of image file
%
%     meta  :     Metadata associated with that image

% CONSTANTS
ROIDIR = 'ROI';

% ITERATOR
n = numel(F);
if n > 1
   data = cell(n,1);
   meta = struct(...
       'Name',cell(n,1),...
       'Group',cell(n,1),...
       'Area',cell(n,1),...
       'Hemisphere',cell(n,1));
   for ii = 1:numel(F)
      [data{ii},meta(ii)] = getMaskedPixelData(F(ii),thresh);
   end
   return;
end


% GET IMAGE AND METADATA

imfile = fullfile(F.folder,F.name);
[I,dim] = readJP2(imfile);
I = I.';

[~,fdata,~] = fileparts(imfile);
meta = extractMetadata(fdata);

% GET ROI FOR DIFFERENT ROIS ON THIS IMAGE
roiDir= fullfile(F.folder,ROIDIR);

sROI = ReadImageJROI(fullfile(roiDir,[fdata '.roi']));
sRegion = ROIs2Regions({sROI},[dim(2) dim(1)]);
data = double(I(sRegion.PixelIdxList{1}));

idx = (data <= thresh(1)) | (data >= thresh(2));
data(idx) = [];

end