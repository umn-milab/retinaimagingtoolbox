function [ind, im] = rit_FindFeaturePoints( im, K, vis )
%
%
% IMPLEMENTED BY:
% Radim Kolar, Brno University of Technology, Department of Biomedical
% Engineering, Faculty of Electrical Engineering and Communication,
% Created in 2016, corrected and submitted to Github in 03/2021.
%
% CITE AS:
% Kolar R, Tornow R P, Odstrcilik J, Liberdova I (2016) "Registration of retinal sequences
% from new video-ophthalmoscopic camera." Biomedical Engineering Online, 15(1), 1-17.
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

%% Preprocessing
if size(im,3)==3
    im = double(rgb2gray(im) );
end
im_orig = im;

im = medfilt2( im, [5 5]);
im = double( adapthisteq(uint8(im)) );
im = rit_BloodVesselDetection( im, 0 );
im = rit_ImageNorm( im, [0 1]);

% im = vessel_Processing( im, ones(size(im)), 11 );
%% Thresholding
Topt = K*rit_ThresholdKittler( im(11:end-10, 11:end-10) );  % Ralf
tmp = zeros( size( im) );
ind = find( im>Topt /10);
tmp(ind) = 1;

%% Postprocessing
% MarginX = 5; % Ralf
% MarginY = 5; % Ralf
% % 
MarginX = 100; % Ralf
MarginY = 60; % Ralf

% Clean Margin
tmp( 1:MarginY, : ) = 0;
tmp( end-MarginY:end, : ) = 0;
tmp( :, 1:MarginX ) = 0;
tmp( :, end-MarginX:end ) = 0;

% Clean Small Regions
% % [L,N] = bwlabeln( tmp );
% % for ii = 1:N
% %     ind = find( L==ii );
% % %     if length( ind )<500
% %         if length( ind )<200
% %         tmp(ind) = 0;
% %     end
% % end

% Create Skeleton
tmp2 = tmp;
tmp2 = bwmorph( tmp2, 'spur' );
tmp2 = bwmorph( tmp, 'thin', Inf );
tmp2 = bwmorph( tmp2,  'spur');
[l, num] = bwlabeln( tmp2 );

for ii = 1:num
    ind = find(l==ii);
    if numel( ind ) <100
        tmp2(ind) = 0;
    end
end


% Find Location
ind = find( tmp2~=0);
% Take only half points
% ind = ind(1:8:end);

if nargout==1, im=[]; end

%% 
if vis==1
%     figure(1); 
%     subplot(411); imshow( im(6:end-5, 6:end-5), []);
%     subplot(412); imhist( im(6:end-5, 6:end-5) );
%     subplot(413); imshow( tmp, []);
%     subplot(414); imshow( tmp2, []);
    figure(1); 
    subplot(221);  imshow( im_orig(6:end-5, 6:end-5), []);
    subplot(222); imshow( im(6:end-5, 6:end-5), []);

%     figure(2);
    subplot(223); imhist( im(6:end-5, 6:end-5) );
    hold on
    line([Topt Topt], [ 0 10000])
%     subplot(221); imshow( tmp, []);
    subplot(224); imshow( tmp2, []);
    
    im_orig(ind) = max(max(im_orig)); % 200;
    figure(2);
    imshow( im_orig, [] );
    
end
end
