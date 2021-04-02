function [PCA_coeff, PCA_com_image, ICA_com_image, ICA_coeff, explained_cumulative] = ...
    rit_bss(image_sequence, ncomponents, varargin)
%RIT_BSS estimates spatial blind source separation of an aligned video recording (i.e. 3D array)
%   via principal component analysis and independent component analysis
%
%   [PCA_coeff, PCA_com_image, ICA_com_image, ICA_coeff, explained_cumulative] = ...
%       RIT_BSS(image_sequence, ncomponents, varargin)
%       estimates ncomponets spatial principal components PCA_com_image and their timecourses PCA_coeff,
%       ncomponents spatial independent components ICA_com_image and their timecourses ICA_coeff
%       and percentils of cumulative explained data variability explained_cumulative. 
%
%   REQUIRED INPUTS:
%   image_sequence must be a 3D array of type double where 1st and 2nd dimensions are space
%   and the 3rd dimension is time.
%
%   ncomponents is a positive integer <= size(image_sequence,3)
%
%   OPTIONAL INPUTS:
%   RIT_BSS(image_sequence, ncomponents, HPf) where HPf is a two value row vector defining
%   parameters of a high-pass filter of a timecourse of each pixel. First
%   vector value is the video temporal sampling frequency (i.e. frame rate or fps).
%   Second vector value is the cut-off frequency in Hz units.
%   Default value is set to [0,0] which means the high-pass filtering is off.
%
%   RIT_BSS(image_sequence, ncomponents, HPf, Mask) where Mask is a
%   logical matrix or black & white image of type double defining region
%   of interest where the blind source separation is estimated.
%   Default value is set to the whole field of view:
%
%   RIT_BSS(image_sequence, ncomponents, HPf, Mask, N) where N is a binary
%   operator of value 0 or 1 deciding whether timecourse normalization of each 
%   pixel is (value 1) or is not (value 0) normalized to mean = 0 and standard 
%   deviation = 1.
%   If high-pass filtering is also turned on, then the high pass filtering
%   precedes the normalization.
%   Default value is set to 0.
%
%   EXAMPLE:
%   [PCA_coeff, PCA_com_image, ICA_com_image, ICA_coeff, explained_cumulative] = ...
%       rit_bss(image_sequence, 4, [25 0.667],Mask,1);
%
%   COMPULSORY TOOLBOX:
%   To run the fastica command, the fastica algorithm is needed to download and 
%   setup in MATLAB session, the toolbox is publicly available at:
%   https://research.ics.aalto.fi/ica/fastica/
%
%   CITE AS:
%   Labounkova I, Labounek R, Nestrasil I, Odstrcilik J, Tornow R P, Kolar R, (2021)
%   "Blind Source Separation of Retinal Pulsatile Patterns in Optic Nerve Head
%   Video-Recordings." IEEE Transactions on Medical Imaging, 40(3), 852-864.
%
%   If you use the fastica algorithm, please CITE ALSO:
%   Hyvarinen A and Oja E (1997) "A Fast Fixed-Point Alogrithm for Independent
%   Component Analysis." Neural Computation, 9(7), 1483-1492.
%
% Copyright 2020-2021 Ivana Labounkova(1,2), Rene Labounek(2), Igor Nestrasil(2,3),
%     Jan Odstrcilik(1), Ralf P. Tornow(4), Radim Kolar(1)
% (1) Department of Biomedical Engineering, Brno University of Technology, Brno, Czech Republic
% (2) Division of Clinical Behavioral Neuroscience, Department of Pediatrics, University of Minnesota, Minneapolis, USA
% (3) Center for Magnetic Resonance Research, Department of Radiology, University of Minnesota, Minneapolis, USA
% (4) Department of Ophthalmology, Friedrich-Alexander University of Erlangen-Nuremberg, Erlangen, Germany
% 
% This file is part of Retina Imaging Toolbox available at: https://github.com/ivanalabounkova/retinaimagingtoolbox
% 
% Retina Imaging Toolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or any later version.
% 
% Retina Imaging Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Retina Imaging Toolbox.  If not, see <https://www.gnu.org/licenses/>.
% 
% Papers related to specific RIT functions are listed in the cite_papers.txt file.

%%
   [xdim,ydim,frames] = size(image_sequence);
   defaultMask = ones(xdim,ydim);
   defaultN = 0;
   defaultHPf = [0,0];
   
   p = inputParser;
   addRequired(p,'image_sequence', @(x) isnumeric(x)); %&& size(x,1)>1 && size(x,2)>1);
   addRequired(p,'ncomponents', @(x) isnumeric(x) && isscalar(x));
   addOptional(p,'HPf', defaultHPf, @(x) isnumeric(x) && length(x)==2);% && isscalar(x) && (x > 0 && x <= 1));
   addOptional(p,'Mask', defaultMask, @(x) size(x,1)>1 && size(x,2)>1 && sum(double(x(:)))>0 && sum(ismember(unique(double(x(:)))', [0,1]))>0 ); %isequal(unique(double(x(:)))', [0,1])
   addOptional(p, 'N', defaultN, @(x) isnumeric(x) && ismember(x, [0,1]));
   parse(p, image_sequence, ncomponents ,varargin{:});
   clear image_sequence
   %%
    fps = p.Results.HPf(1);
    fm = p.Results.HPf(2);
    BW3D = reshape((repmat(p.Results.Mask,1,1,frames)),[], frames);
    PCA_com_image = zeros(xdim,ydim,frames);  
    %%
    IS_T = reshape(p.Results.image_sequence,xdim*ydim,frames);
    IS_T = reshape(IS_T(BW3D == 1),[],frames);  
    if sum(p.Results.HPf)~=0 || p.Results.N~=0    
        for px = 1:size(IS_T, 1)         
            if sum(p.Results.HPf)~=0
                Ns = ceil((fm(1)*frames)/fps);              
                PX = fft(IS_T(px,:));
                PX([(1:(Ns(1)-1)) ((end-Ns(1)+3):(end))]) = 0;
                IS_T(px,:) = real(ifft((PX)));
            end          
            if p.Results.N == 1              
                IS_T(px,:) = ( IS_T(px,:) - mean(IS_T(px,:)) ) / std(IS_T(px,:));
            end
        end
    end   
    %% spatial PCA
    [PCA_coeff,score,~,~,explained,~] = pca(IS_T);
    explained_cumulative = cumsum(explained);
    PCA_com_image(BW3D == 1) = reshape(score,[],1);
    coeff_reduced = PCA_coeff;
    coeff_reduced(:,ncomponents+1:end) = 0;
    PCA_com_image = PCA_com_image(:,:,1:ncomponents);
    PCA_coeff = PCA_coeff(:,1:ncomponents);
    %% spatial ICA
    [icasig, ICA_coeff, ~] = fastica((score*coeff_reduced')','approach','symm');
    ICA_com_image = zeros(xdim*ydim, size(icasig,1));
    ICA_com_image(BW3D(:,1:(size(icasig,1)))==1) = reshape(icasig',[],1);
    ICA_com_image = reshape(ICA_com_image, xdim, ydim, size(icasig,1));
end
