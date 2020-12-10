function [I,dim] = readJP2(imfile)
%% READJP2   READ JP2 FILE AND GET DIMENSIONS
%
%  [I,dim] = READJP2(imfile);
%
%  --------
%   INPUTS
%  --------
%   imfile     :     Image file name
%
%  --------
%   OUTPUT
%  --------
%     I        :     Grayscale uint8 image
%
%    dim       :     Dimensions ([Height, Width]) of image
%
% By: Max Murphy  v1.0  2019-04-18  Original version (R2017a)

%%
I = imread(imfile);
dim = size(I);

end