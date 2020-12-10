function [data,meta] = getMaskedPixelData(F,thresh,fname)
%GETMASKEDPIXELDATA   Get pixels masked by ROIs of interest
%
%  [data,meta] = GETMASKEDPIXELDATA(F,thresh);
%  [data,meta] = GETMASKEDPIXELDATA(F,thresh,fname);
%
%  --------
%   INPUTS
%  --------
%      F      :     File struct from DIR that points to image file.
%      thresh :     Intensity thresholds for exclusion
%      fname  :     (Char or string; optional) Name of local intensity data
%                    file. Default is 'IntensityData'. If this file is
%                    detected, then image data is loaded directly instead
%                    of scraped from *.tif files on server.
%
%  --------
%   OUTPUT
%  --------
%     data  :     Pixel data from thresholded regins of image file
%
%     meta  :     Metadata associated with that image

% CONSTANTS
ROIDIR = 'ROI';
FNAME_DEF = 'IntensityData.mat';

if nargin < 3
   fname = FNAME_DEF;
end
[p,f,~] = fileparts(fname);
fname = string(fullfile(string(p),strcat(string(f),".mat")));

if exist(fname,'file')==0
   % ITERATOR
   n = numel(F);
   if n > 1
      tic;
      fprintf(1,'No local copy of <strong>%s</strong>. Extracting from server.\n',fname);
      fprintf(1,'\t->\t<strong>SERVER:</strong> `%s`\n\n',F(1).folder);
      data = cell(n,1);
      meta = struct(...
          'Name',cell(n,1),...
          'Group',cell(n,1),...
          'Area',cell(n,1),...
          'Hemisphere',cell(n,1));
      for ii = 1:numel(F)
         [data{ii},meta(ii)] = getMaskedPixelData(F(ii),thresh);
      end
      fprintf(1,'\t->\tMasked pixel intensity extraction complete. (%5.2f sec)\n',toc);
      tic;
      fprintf(1,'\t\t->\tSaving local copy to <strong>%s</strong>...',fname);
      save(fname,'data','meta','-v7.3');
      fprintf(1,'complete (%5.2f sec)\n',toc);
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
else
   tic;
   fprintf(1,'Detected local copy of <strong>%s</strong>. Loading...',fname);
   in = load(fname,'data','meta');
   data = in.data;
   meta = in.meta;
   fprintf(1,'complete (%5.2f sec)\n',toc);
end

end