function [Zw, T] = whitenRows(Z)
%WHITENROWS  Whitens rows of (d x n) matrix Z containing n samples
%
%  [Zw, T] = math__.whitenRows(Z);
%               
% Inputs:       Z is an (d x n) matrix containing n samples of a
%               d-dimensional random vector
%
% Outputs:      Zw is the whitened version of Z
%               
%               T is the (d x d) whitening transformation of Z
%               
% Description:  Returns the whitened (identity covariance) version of the
%               input data
%               
% Notes:        (a) Must have n >= d to fully whitenRows Z
%               
%               (b) Z = (Zcw' / T')'
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         November 1, 2016
%
% Update:       March   31, 2020 -- m053m716
%               * Switch `cov` to `nancov` for matrices with missing data

% Compute sample covariance
R = nancov(Z');

% Whiten data
[U, S, ~] = svd(R);
T  = U * diag(1 ./ sqrt(diag(S))) * U';
Zw = T * Z;

end